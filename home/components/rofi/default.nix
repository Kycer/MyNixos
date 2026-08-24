{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  desktop = osConfig.my.desktop;
  enabled =
    desktop.session.enable && desktop.shellStyle == "custom" && desktop.custom.launcher == "rofi";
in
{
  config = lib.mkIf enabled {
    home.packages = [ pkgs.rofi ];
    my.desktop.session.commandBindings."Mod+D" = [
      "rofi"
      "-show"
      "drun"
    ];
  };
}
