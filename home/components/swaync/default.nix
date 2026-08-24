{ lib, osConfig, ... }:

let
  desktop = osConfig.my.desktop;
  enabled =
    desktop.session.enable && desktop.shellStyle == "custom" && desktop.custom.notification == "swaync";
in
{
  config = lib.mkIf enabled {
    services.swaync.enable = true;
  };
}
