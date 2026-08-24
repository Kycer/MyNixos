{
  config,
  lib,
  osConfig,
  ...
}:

let
  desktop = osConfig.my.desktop;
  enabled =
    desktop.session.enable && desktop.shellStyle == "custom" && desktop.custom.bar == "waybar";
  adapter = config.my.desktop.session.waybar;
  baseSettings = builtins.fromJSON (builtins.readFile ./config.jsonc);
  settings = (builtins.removeAttrs baseSettings adapter.removeModules) // adapter.settings;
in
{
  config = lib.mkIf enabled {
    programs.waybar = {
      enable = true;
      settings = [ settings ];
      style = ./style.css;
      systemd.enable = true;
      systemd.targets = [ config.wayland.systemd.target ];
    };
  };
}
