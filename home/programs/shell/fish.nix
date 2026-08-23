{ lib, osConfig, ... }:

{
  config = lib.mkIf (osConfig.my.user.shell == "fish") {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
    };
  };
}
