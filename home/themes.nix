{ config, lib, pkgs, osConfig, ... }:

let
  t = osConfig.my.theme;
in
{
  home.packages = [
    t.gtkTheme.package
    t.iconTheme.package
    t.cursor.package
    pkgs.qt6Packages.qt6ct
  ];

  gtk = {
    enable = true;
    theme = {
      name = t.gtkTheme.name;
      package = t.gtkTheme.package;
    };
    iconTheme = {
      name = t.iconTheme.name;
      package = t.iconTheme.package;
    };
    font = {
      name = t.font.name;
      size = t.font.size;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = t.cursor.name;
      gtk-cursor-theme-size = t.cursor.size;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = t.cursor.name;
      gtk-cursor-theme-size = t.cursor.size;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = t.cursor.name;
    size = t.cursor.size;
    package = t.cursor.package;
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = "kvantum";

    qt5ctSettings = {
      Appearance = {
        custom_palette = false;
        icon_theme = t.iconTheme.name;
        style = "Kvantum";
      };
      Fonts = {
        general = "${t.font.name},${toString t.font.size},-1,5,50,0,0,0,0,0";
      };
    };

    qt6ctSettings = {
      Appearance = {
        custom_palette = false;
        icon_theme = t.iconTheme.name;
        style = "Kvantum";
      };
      Fonts = {
        general = "${t.font.name},${toString t.font.size},-1,5,50,0,0,0,0,0";
      };
    };
  };



  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = t.gtkTheme.name;
      icon-theme = t.iconTheme.name;
    };
  };
}
