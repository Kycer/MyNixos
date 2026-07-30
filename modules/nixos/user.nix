{ config, pkgs, ... }:

let
  cfg = config.my.user;
  shells = {
    bash = pkgs.bashInteractive;
    zsh = pkgs.zsh;
  };
in
{
  programs.zsh.enable = cfg.shell == "zsh";

  users.users.${cfg.name} = {
    isNormalUser = true;
    extraGroups = cfg.extraGroups;
    openssh.authorizedKeys.keys = cfg.authorizedKeys;
    shell = shells.${cfg.shell};
  };
}
