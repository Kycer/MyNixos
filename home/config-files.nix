{ config, ... }:

let
  configRoot = "${config.home.homeDirectory}/.nixos/config";
  liveLink =
    path:
    config.lib.file.mkOutOfStoreSymlink "${configRoot}/${path}";
in
{
  xdg.configFile = {
    "foot".source = liveLink "foot";
    "niri".source = liveLink "niri";
    "nvim".source = liveLink "nvim";
    "sway".source = liveLink "sway";
    "gtk-3.0".source = liveLink "gtk-3.0";
    "gtk-4.0".source = liveLink "gtk-4.0";
    "qt5ct".source = liveLink "qt5ct";
    "qt6ct".source = liveLink "qt6ct";

    # `just -g <recipe>` uses this file from any working directory.
    "just/justfile".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/justfile";
  };
}
