{ config, lib, osConfig, pkgs, ... }:

let
  cfg = osConfig.my.desktop;
in
{
  config = lib.mkIf (cfg.wm == "sway") {
    xdg.configFile."sway/config".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.nixos/home/desktops/sway/config";

    wayland.systemd.target = "sway-session.target";
  };
}

