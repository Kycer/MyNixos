{ config, pkgs, ... }:

let
  cfg = config.my.user;
  shells = {
    fish = pkgs.fish;
    zsh = pkgs.zsh;
  };
in
{
  programs = {
    fish.enable = cfg.shell == "fish";
    zsh.enable = cfg.shell == "zsh";
  };

  users.users.${cfg.name} = {
    isNormalUser = true;
    extraGroups = cfg.extraGroups;
    openssh.authorizedKeys.keys = cfg.authorizedKeys;
    shell = shells.${cfg.shell};
  };
}
