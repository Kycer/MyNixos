{ config, pkgs, ... }:

let
  cfg = config.my.user;
  shells = {
    inherit (pkgs) fish zsh;
  };
in
{
  programs = {
    fish.enable = cfg.shell == "fish";
    zsh.enable = cfg.shell == "zsh";
  };

  users.users.${cfg.name} = {
    isNormalUser = true;
    inherit (cfg) extraGroups;
    openssh.authorizedKeys.keys = cfg.authorizedKeys;
    shell = shells.${cfg.shell};
  };
}
