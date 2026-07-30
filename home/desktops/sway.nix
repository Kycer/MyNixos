{ lib, osConfig, pkgs, ... }:

{
  config = lib.mkIf (osConfig.my.desktop == "sway") {
    home.packages = with pkgs; [
      foot
      fuzzel
      nautilus
      waybar
      wireplumber
      yazi
    ];

    wayland.systemd.target = "sway-session.target";
  };
}
