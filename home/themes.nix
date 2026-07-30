{ pkgs, ... }:

let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    accents = [ "lavender" ];
    size = "standard";
    tweaks = [ ];
    variant = "macchiato";
  };
in
{
  home.packages = with pkgs; [
    adwaita-icon-theme
    adwaita-qt
    adwaita-qt6
    catppuccinGtk
    papirus-icon-theme
    qt6Packages.qt6ct
  ];

  home.sessionVariables = {
    GTK_THEME = "catppuccin-macchiato-lavender-standard";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "Adwaita-Dark";
  };
}
