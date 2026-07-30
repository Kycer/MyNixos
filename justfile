set default-list := true
set shell := ["bash", "-euo", "pipefail", "-c"]

host := env("NIXOS_HOST", "cloudbox")
flake := env("NIXOS_FLAKE", home_directory() / ".nixos")

# 检查所有 flake 输出，但不构建软件包。
check:
  nix flake check "{{flake}}"

# 构建当前主机配置，但不激活。
build:
  sudo nixos-rebuild build --flake "{{flake}}#{{host}}"

# 构建并立即激活当前主机配置。
switch:
  sudo nixos-rebuild switch --flake "{{flake}}#{{host}}"

# 临时激活配置，重启后恢复原来的启动配置。
test:
  sudo nixos-rebuild test --flake "{{flake}}#{{host}}"

# 构建配置，并设置为下次启动时使用。
boot:
  sudo nixos-rebuild boot --flake "{{flake}}#{{host}}"

# 更新 flake.lock；切换系统前应先检查更新内容并运行 check。
update:
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
