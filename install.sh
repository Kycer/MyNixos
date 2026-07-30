#!/usr/bin/env bash

set -Eeuo pipefail

readonly script_name="${0##*/}"
readonly default_host="${NIXOS_HOST:-cloudbox}"
readonly default_target="${NIXOS_CONFIG_DIR:-$HOME/.nixos}"

repo_url=""
host="$default_host"
target="$default_target"
branch=""
install_user="${USER:-$(id -un)}"
assume_yes=false
update_checkout=false
check_only=false

usage() {
  cat <<EOF
用法：
  $script_name --repo <Git 仓库地址> [选项]
  $script_name [选项]  # 已在仓库中执行时可省略 --repo

选项：
  --repo <URL>       Git 仓库地址
  --host <名称>      要安装的 NixOS host，默认：$default_host
  --branch <名称>    克隆指定分支
  --target <路径>    配置安装目录，默认：$default_target
  --user <用户名>    写入 host 的主用户，默认：$install_user
  --update           对已存在的 Git 仓库执行 git pull --ff-only
  --check-only       只克隆/更新并检查配置，不修改 /etc/nixos，不切换系统
  -y, --yes          不询问确认，直接执行
  -h, --help         显示帮助

示例：
  $script_name --repo https://github.com/Kycer/MyNixos.git
  $script_name --repo git@github.com:Kycer/MyNixos.git --host cloudbox --yes
EOF
}

die() {
  printf '错误：%s\n' "$*" >&2
  exit 1
}

info() {
  printf '==> %s\n' "$*"
}

confirm() {
  local reply

  if "$assume_yes"; then
    return 0
  fi

  read -r -p "$1 [y/N] " reply
  [[ "$reply" == "y" || "$reply" == "Y" ]]
}

while (($# > 0)); do
  case "$1" in
    --repo)
      (($# >= 2)) || die "--repo 缺少参数"
      repo_url="$2"
      shift 2
      ;;
    --host)
      (($# >= 2)) || die "--host 缺少参数"
      host="$2"
      shift 2
      ;;
    --branch)
      (($# >= 2)) || die "--branch 缺少参数"
      branch="$2"
      shift 2
      ;;
    --target)
      (($# >= 2)) || die "--target 缺少参数"
      target="$2"
      shift 2
      ;;
    --user)
      (($# >= 2)) || die "--user 缺少参数"
      install_user="$2"
      shift 2
      ;;
    --update)
      update_checkout=true
      shift
      ;;
    --check-only)
      check_only=true
      shift
      ;;
    -y | --yes)
      assume_yes=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "未知参数：$1"
      ;;
  esac
done

[[ "$EUID" -ne 0 ]] || die "请使用普通用户运行脚本；需要权限时脚本会调用 sudo"
[[ "$install_user" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "用户名格式无效：$install_user"
[[ "$host" =~ ^[a-zA-Z0-9_-]+$ ]] || die "host 名称格式无效：$host"

target="${target/#\~/$HOME}"
[[ "$target" == /* ]] || die "--target 必须是绝对路径"

for command_name in nix sudo; do
  command -v "$command_name" >/dev/null || die "找不到命令：$command_name"
done

export NIX_CONFIG=$'experimental-features = nix-command flakes\n'"${NIX_CONFIG:-}"

if command -v git >/dev/null; then
  git_command=(git)
else
  info "系统未安装 Git，将通过 nix shell 临时使用 Git"
  git_command=(nix shell nixpkgs#git --command git)
fi

run_git() {
  "${git_command[@]}" "$@"
}

script_dir=""
script_source="${BASH_SOURCE[0]-}"
if [[ -n "$script_source" ]]; then
  script_dir="$(cd -- "$(dirname -- "$script_source")" && pwd)"
fi

if [[ ! -e "$target" ]]; then
  if [[ -z "$repo_url" && -n "$script_dir" && -d "$script_dir/.git" ]]; then
    repo_url="$(run_git -C "$script_dir" remote get-url origin 2>/dev/null || true)"
  fi

  [[ -n "$repo_url" ]] || die "目标目录不存在，请通过 --repo 指定 Git 仓库"

  clone_args=(clone)
  if [[ -n "$branch" ]]; then
    clone_args+=(--branch "$branch")
  fi
  clone_args+=(-- "$repo_url" "$target")

  info "克隆配置到 $target"
  run_git "${clone_args[@]}"
elif [[ ! -d "$target/.git" ]]; then
  die "目标已存在但不是 Git 仓库：$target"
elif "$update_checkout"; then
  info "更新现有配置"
  run_git -C "$target" pull --ff-only
else
  info "使用现有配置：$target"
fi

host_file="$target/hosts/$host/default.nix"
[[ -f "$host_file" ]] || die "找不到 host 配置：$host_file"
grep -q '^[[:space:]]*name = ".*"; # installer:user$' "$host_file" ||
  die "$host_file 缺少 installer:user 标记"

info "将 $host 的主用户设置为 $install_user"
sed -i -E \
  's/^([[:space:]]*)name = "[^"]*"; # installer:user$/\1name = "'"$install_user"'"; # installer:user/' \
  "$host_file"

export NIXOS_HOST="$host"
export NIXOS_FLAKE="$target"

run_just() {
  nix shell nixpkgs#just --command \
    just --justfile "$target/justfile" "$@"
}

info "检查 flake"
run_just check

if "$check_only"; then
  info "检查完成；未修改 /etc/nixos，也未切换系统"
  exit 0
fi

confirm "将备份现有 /etc/nixos、建立软链接并切换到 $host，是否继续？" ||
  die "用户取消"

sudo -v

resolved_etc_nixos="$(readlink -f /etc/nixos 2>/dev/null || true)"
resolved_target="$(readlink -f "$target")"

if [[ "$resolved_etc_nixos" != "$resolved_target" ]]; then
  if sudo test -e /etc/nixos || sudo test -L /etc/nixos; then
    backup_path="/etc/nixos.before-flake.$(date +%Y%m%d-%H%M%S)"
    info "备份 /etc/nixos 到 $backup_path"
    sudo mv -- /etc/nixos "$backup_path"
  fi

  info "建立 /etc/nixos -> $target"
  sudo ln -s -- "$target" /etc/nixos
else
  info "/etc/nixos 已指向 $target"
fi

info "构建并切换 NixOS"
run_just switch

printf '\n安装完成。\n'
printf '重新登录或执行 exec zsh -l 后，可以使用：\n'
printf '  j switch\n'
printf '  just -g switch\n'
