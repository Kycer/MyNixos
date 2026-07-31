{ config, lib, pkgs, osConfig, ... }:

let
  cfg = osConfig.my.desktop;
  enabled = (cfg.wm != "none") && (cfg.shellStyle == "custom") && (cfg.custom.notification == "swaync");
in
{
  config = lib.mkIf enabled {
    home.packages = [ pkgs.swaynotificationcenter ];
    xdg.configFile."swaync".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.nixos/home/components/swaync";
  };
}
