{
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  config = lib.mkIf (osConfig.my.desktop == "niri") {
    home.packages = with pkgs; [
      brightnessctl
      foot
      fuzzel
      nautilus
      swaylock
      wireplumber
      xwayland-satellite
      yazi
    ];
  };
}
