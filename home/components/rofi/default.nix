{ config, lib, pkgs, osConfig, ... }:

let
  cfg = osConfig.my.desktop;
  isRofiEnabled = (cfg.wm != "none") && (cfg.shellStyle == "custom") && (cfg.custom.launcher == "rofi");
  isSway = cfg.wm == "sway";
  isNiri = cfg.wm == "niri";
in
{
  config = lib.mkIf isRofiEnabled (lib.mkMerge [
    {
      home.packages = [ pkgs.rofi ];
      xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/home/components/rofi";
    }

    (lib.mkIf isSway {
      xdg.configFile."sway/config.d/rofi.conf".text = ''
        set $menu rofi -show drun
      '';
    })

    (lib.mkIf isNiri {
      xdg.configFile."niri/config.d/rofi.kdl".text = ''
        binds {
            Mod+D { spawn "rofi" "-show" "drun"; }
        }
      '';
    })
  ]);
}
