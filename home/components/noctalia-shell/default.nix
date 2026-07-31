{ config, lib, pkgs, osConfig, ... }:

let
  cfg = osConfig.my.desktop;
  isNoctaliaEnabled = (cfg.wm != "none") && (cfg.shellStyle == "noctalia-shell");
  isSway = cfg.wm == "sway";
  isNiri = cfg.wm == "niri";
in
{
  config = lib.mkIf isNoctaliaEnabled (lib.mkMerge [
    {
      home.packages = [ pkgs.noctalia ];
      xdg.configFile."noctalia".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/home/components/noctalia-shell";
    }

    (lib.mkIf isSway {
      xdg.configFile."sway/config.d/noctalia.conf".text = ''
        exec_always --no-startup-id noctalia-shell
      '';
    })

    (lib.mkIf isNiri {
      xdg.configFile."niri/config.d/noctalia.kdl".text = ''
        spawn-at-startup "noctalia-shell"
      '';
    })
  ]);
}

