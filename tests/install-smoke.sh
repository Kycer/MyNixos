#!/bin/bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$repo_root/install.sh"
test_root="$(mktemp -d /tmp/mynixos-install-test.XXXXXX)"
trap 'rm -rf -- "$test_root"' EXIT

make_common_bin() {
  local bin_dir="$1"

  /usr/bin/mkdir -p "$bin_dir"
  /usr/bin/ln -s /usr/bin/grep "$bin_dir/grep"
  /usr/bin/ln -s /usr/bin/sed "$bin_dir/sed"
  /usr/bin/ln -s /usr/bin/true "$bin_dir/sudo"
}

with_git_root="$test_root/with-git"
with_git_bin="$with_git_root/bin"
with_git_target="$with_git_root/home/.nixos"
make_common_bin "$with_git_bin"
/usr/bin/ln -s /usr/bin/true "$with_git_bin/git"
/usr/bin/ln -s /usr/bin/true "$with_git_bin/nix"
/usr/bin/mkdir -p \
  "$with_git_target/.git" \
  "$with_git_target/hosts/cloudbox"
printf '%s\n' \
  '{ pkgs, ... }:' \
  '{' \
  '  name = "old-user"; # installer:user' \
  '}' >"$with_git_target/hosts/cloudbox/default.nix"

with_git_output="$(
  PATH="$with_git_bin" \
    HOME="$with_git_root/home" \
    USER="test-user" \
    /bin/bash -s -- \
      --target "$with_git_target" \
      --host cloudbox \
      --check-only <"$installer" 2>&1
)"
/usr/bin/grep -q '检查完成' <<<"$with_git_output"

without_git_root="$test_root/without-git"
without_git_bin="$without_git_root/bin"
without_git_target="$without_git_root/home/.nixos"
make_common_bin "$without_git_bin"
/usr/bin/cp "$repo_root/tests/fake-nix.sh" "$without_git_bin/nix"
/usr/bin/chmod +x "$without_git_bin/nix"

without_git_output="$(
  PATH="$without_git_bin" \
    HOME="$without_git_root/home" \
    USER="test-user" \
    /bin/bash -s -- \
      --repo https://example.invalid/MyNixos.git \
      --target "$without_git_target" \
      --host cloudbox \
      --check-only <"$installer" 2>&1
)"
/usr/bin/grep -q '通过 nix shell 临时使用 Git' <<<"$without_git_output"
/usr/bin/grep -q '检查完成' <<<"$without_git_output"

printf 'install-smoke: PASS\n'
