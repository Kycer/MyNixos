{ config, lib, pkgs, osConfig, ... }:

let
  cfg = osConfig.my.desktop;
  isWaybarEnabled = (cfg.wm != "none") && (cfg.shellStyle == "custom") && (cfg.custom.bar == "waybar");
  isSway = cfg.wm == "sway";
  isNiri = cfg.wm == "niri";
in
{
  config = lib.mkIf isWaybarEnabled (lib.mkMerge [
    {
      programs.waybar.enable = true;
      xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/home/components/waybar";
    }

    (lib.mkIf isSway {
      xdg.configFile."sway/config.d/waybar.conf".text = ''
        exec_always --no-startup-id sh -c 'pkill -x waybar || true; exec waybar --config ~/.nixos/home/components/waybar/config.jsonc --style ~/.nixos/home/components/waybar/style.css'
      '';
    })

    (lib.mkIf isNiri {
      xdg.configFile."niri/config.d/waybar.kdl".text = ''
        spawn-at-startup "sh" "-c" "pkill -x waybar || true; exec waybar --config ~/.nixos/home/components/waybar/config.jsonc --style ~/.nixos/home/components/waybar/style.css"
      '';
    })
  ]);
}

