{ config, lib, osConfig, pkgs, ... }:

let
  cfg = osConfig.my.desktop;
in
{
  config = lib.mkIf (cfg.wm == "niri") {
    home.packages = [ pkgs.xwayland-satellite ];

    xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.nixos/home/desktops/niri/config.kdl";
    xdg.configFile."niri/noctalia.kdl".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.nixos/home/desktops/niri/noctalia.kdl";
  };
}

