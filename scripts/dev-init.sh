#!/usr/bin/env bash
set -Eeuo pipefail

if (($# != 2)); then
  echo "用法：dev-init.sh <配置仓库> <语言列表>" >&2
  exit 2
fi

config_repo="$(realpath -e -- "$1")"
language_words="$2"
renderer="${config_repo}/lib/render-dev-flake.nix"

if [[ -e flake.nix || -e flake.lock || -e .envrc ]]; then
  echo "错误：当前目录已经存在 flake.nix、flake.lock 或 .envrc。" >&2
  exit 1
fi

read -r -a languages <<<"$language_words"

language_json="["
separator=""
for language in "${languages[@]}"; do
  if [[ ! "$language" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "错误：无效的语言名称：$language" >&2
    exit 1
  fi

  language_json+="${separator}\"${language}\""
  separator=","
done
language_json+="]"

export MYNIXOS_DEV_RENDERER="$renderer"
export MYNIXOS_DEV_LANGUAGES="$language_json"

rendered_flake=""
rendered_envrc=""
cleanup() {
  if [[ -n "$rendered_flake" ]]; then
    rm -f -- "$rendered_flake"
  fi
  if [[ -n "$rendered_envrc" ]]; then
    rm -f -- "$rendered_envrc"
  fi
}
trap cleanup EXIT

rendered_flake="$(mktemp "${PWD}/.flake.nix.XXXXXX")"
rendered_envrc="$(mktemp "${PWD}/.envrc.XXXXXX")"

nix eval --raw --impure --expr '
  import (builtins.toPath (builtins.getEnv "MYNIXOS_DEV_RENDERER")) {
    languages = builtins.fromJSON (builtins.getEnv "MYNIXOS_DEV_LANGUAGES");
  }
' >"$rendered_flake"

printf '%s\n' 'use flake' >"$rendered_envrc"

mv -- "$rendered_flake" flake.nix
rendered_flake=""
mv -- "$rendered_envrc" .envrc
rendered_envrc=""
trap - EXIT

nix flake lock "path:$PWD"

echo "==> 已创建开发环境：${languages[*]}"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "==> 先运行 git add flake.nix flake.lock .envrc，使 Git Flake 能读取新文件"
fi
echo "==> 首次使用请运行 direnv allow"
