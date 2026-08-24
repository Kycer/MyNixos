{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  desktop = osConfig.my.desktop;
  enabled = desktop.session.enable && desktop.shellStyle == "noctalia";
  wallpaperDirectory = "${config.home.homeDirectory}/Pictures/wallpaper";
  wallpaperPath = "${wallpaperDirectory}/74335123_p0.jpg";
  settings = (builtins.fromTOML (builtins.readFile ./config.toml)) // {
    wallpaper = {
      directory = wallpaperDirectory;
      automation.enabled = true;
      default.path = wallpaperPath;
      last.path = wallpaperPath;
      monitors."eDP-1".path = wallpaperPath;
    };
  };
  rawConfig = (pkgs.formats.toml { }).generate "noctalia-config.toml" settings;
  validatedConfig = pkgs.runCommand "noctalia-config.toml" { } ''
    ${lib.getExe pkgs.noctalia} config validate ${rawConfig}
    cp ${rawConfig} "$out"
  '';
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      cliphist
      pwvucontrol
      wl-clipboard
    ];

    # Components publish desktop-neutral commands. The selected desktop
    # adapter renders these into its native startup and keybinding syntax.
    my.desktop.session = {
      autostart.noctalia = [ "noctalia" ];
      commandBindings = {
        "Mod+D" = [
          "noctalia"
          "msg"
          "panel-toggle"
          "launcher"
        ];
        "Mod+B" = [
          "noctalia"
          "msg"
          "bar-toggle"
        ];
        "Mod+Alt+S" = [
          "noctalia"
          "msg"
          "settings-toggle"
        ];
        "Mod+Alt+W" = [
          "noctalia"
          "msg"
          "panel-toggle"
          "wallpaper"
        ];
        "Mod+Shift+X" = [
          "noctalia"
          "msg"
          "session"
          "lock"
        ];
        "Mod+Shift+O" = [
          "noctalia"
          "msg"
          "panel-toggle"
          "clipboard"
        ];
        "Mod+Shift+D" = [
          "noctalia"
          "msg"
          "clipboard-clear"
        ];
      };
    };

    xdg.configFile."noctalia/config.toml".source = validatedConfig;
  };
}
