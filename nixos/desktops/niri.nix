{ config, lib, ... }:

{
  config = lib.mkIf (config.my.desktop.wm == "niri") {
    my.desktop.session = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };

    programs.niri.enable = true;
  };
}
