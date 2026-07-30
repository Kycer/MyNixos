set default-list := true
set shell := ["bash", "-euo", "pipefail", "-c"]

host := env("NIXOS_HOST", "cloudbox")
flake := env("NIXOS_FLAKE", home_directory() / ".nixos")

# 暂存本地改动、拉取远程配置，再恢复本地改动。
pull:
  #!/usr/bin/env bash
  set -Eeuo pipefail

  repo="{{flake}}"
  stashed=false

  if ((EUID == 0)); then
    echo "错误：请使用配置仓库所属的普通用户运行 pull。" >&2
    exit 1
  fi

  git -C "$repo" rev-parse --is-inside-work-tree >/dev/null

  restore_stash() {
    if [[ "$stashed" == true ]]; then
      stashed=false
      echo "==> 恢复拉取前的本地改动"
      git -C "$repo" stash pop --index
    fi
  }

  trap restore_stash EXIT

  if [[ -n "$(git -C "$repo" status --porcelain --untracked-files=normal)" ]]; then
    echo "==> 暂存本地改动"
    git -C "$repo" stash push --include-untracked \
      --message "just pull: temporary local changes"
    stashed=true
  fi

  echo "==> 拉取远程配置"
  git -C "$repo" pull --ff-only

  restore_stash
  trap - EXIT

# 检查所有 flake 输出，但不构建软件包。
check: pull
  nix flake check "{{flake}}"

# 构建当前主机配置，但不激活。
build: pull
  sudo nixos-rebuild build --flake "path:{{flake}}#{{host}}"

# 构建并立即激活当前主机配置。
switch: pull
  sudo nixos-rebuild switch --flake "path:{{flake}}#{{host}}"

# 临时激活配置，重启后恢复原来的启动配置。
test: pull
  sudo nixos-rebuild test --flake "path:{{flake}}#{{host}}"

# 构建配置，并设置为下次启动时使用。
boot: pull
  sudo nixos-rebuild boot --flake "path:{{flake}}#{{host}}"

# 更新 flake.lock；切换系统前应先检查更新内容并运行 check。
update: pull
  nix flake update --flake "{{flake}}"

# 查看 NixOS 系统历史版本。
generations:
  sudo nix-env --profile /nix/var/nix/profiles/system --list-generations

# 回滚并激活上一个系统版本。
rollback:
  sudo nixos-rebuild switch --rollback

# 清理未被引用的 store 路径，包括退出 nix-shell -p 后留下的软件包。
clean-shell:
  sudo nix-collect-garbage

# 清理未被引用的路径，以及超过指定时间的历史版本。
gc age="30d":
  nix-collect-garbage --delete-older-than "{{age}}"
  sudo nix-collect-garbage --delete-older-than "{{age}}"

# 只删除指定目录中由 nix-build 生成的 result 软链接。
clean-results directory=".":
  find "{{directory}}" -maxdepth 1 -type l -name 'result*' -lname '/nix/store/*' -print -delete

# 对 Nix store 中相同的文件进行去重。
optimise:
  sudo nix store optimise

# 使用 nix-shell 自动生成 WireGuard 私钥并输出对应的公钥。
wg-gen-keys:
  #!/usr/bin/env bash
  set -Eeuo pipefail
  sudo mkdir -p /etc/wireguard
  sudo chmod 700 /etc/wireguard
  if [[ -f /etc/wireguard/private.key ]]; then
    echo "提示：/etc/wireguard/private.key 已存在，跳过私钥生成。"
  else
    echo "==> 使用 nix-shell 临时生成 WireGuard 私钥..."
    sudo touch /etc/wireguard/private.key
    sudo chmod 600 /etc/wireguard/private.key
    nix-shell -p wireguard-tools --run "wg genkey" | sudo tee /etc/wireguard/private.key > /dev/null
    echo "==> 私钥已成功保存至 /etc/wireguard/private.key"
  fi
  echo "==> WireGuard 公钥 (Public Key)："
  nix-shell -p wireguard-tools --run "wg pubkey < /etc/wireguard/private.key"

