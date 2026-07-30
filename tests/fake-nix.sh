#!/bin/bash

set -euo pipefail

if [[ "${1-}" == "shell" && "${2-}" == "nixpkgs#git" &&
      "${3-}" == "--command" && "${4-}" == "git" ]]; then
  shift 4

  if [[ "${1-}" == "clone" ]]; then
    target="${@: -1}"
    /usr/bin/mkdir -p "$target/.git" "$target/hosts/cloudbox"
    printf '%s\n' \
      '{ pkgs, ... }:' \
      '{' \
      '  name = "old-user"; # installer:user' \
      '}' >"$target/hosts/cloudbox/default.nix"
    exit 0
  fi
fi

if [[ "${1-}" == "shell" && "${2-}" == "nixpkgs#just" &&
      "${3-}" == "--command" && "${4-}" == "just" ]]; then
  exit 0
fi

printf '测试中的假 nix 收到了未预期的参数：%q ' "$@" >&2
printf '\n' >&2
exit 1
