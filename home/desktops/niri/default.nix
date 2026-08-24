{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.my.desktop;
  session = config.my.desktop.session;
  fragments = config.my.niri.fragments;
  fragmentNames = lib.sort builtins.lessThan (lib.attrNames fragments);
  fragmentFiles = lib.mapAttrs' (
    name: text: lib.nameValuePair "niri/config.d/${name}.kdl" { inherit text; }
  ) fragments;

  renderCommand = command: lib.concatMapStringsSep " " builtins.toJSON command;
  startupNames = lib.sort builtins.lessThan (lib.attrNames session.autostart);
  startupLines = map (
    name: "spawn-at-startup ${renderCommand session.autostart.${name}}"
  ) startupNames;
in
{
  imports = [
    ./session.nix
    ./outputs.nix
    ./input.nix
    ./layout.nix
    ./rules.nix
    ./binds.nix
  ];

  # Desktop and shell modules contribute ordered KDL fragments here. One
  # module owns config.kdl and the include order; features own only their
  # fragment.
  options.my.niri.fragments = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    default = { };
    internal = true;
    description = "Ordered Niri KDL fragments managed by Home Manager";
  };

  config = lib.mkIf (cfg.wm == "niri") (
    lib.mkMerge [
      {
        my.desktop.session = {
          enable = true;

          # Shell modules can replace the adapter's fallback lock command.
          commandBindings."Mod+Shift+X" = lib.mkDefault [ "swaylock" ];

          waybar = {
            removeModules = [
              "sway/workspaces"
              "sway/mode"
              "sway/window"
            ];
            settings = {
              modules-left = [ "niri/workspaces" ];
              modules-center = [ "niri/window" ];

              "niri/workspaces" = {
                all-outputs = true;
                format = "{index}";
              };

              "niri/window" = {
                max-length = 70;
                icon = true;
                icon-size = 16;
              };
            };
          };
        };

        home.packages = with pkgs; [
          brightnessctl
          swaylock
          xwayland-satellite
        ];

        my.niri.fragments."80-session-startup" = lib.concatStringsSep "\n" startupLines;

        xdg.configFile = fragmentFiles // {
          "niri/config.kdl".text =
            lib.concatMapStringsSep "\n" (name: ''include "config.d/${name}.kdl"'') fragmentNames + "\n";
        };
      }

      (lib.mkIf (cfg.shellStyle == "noctalia") {
        my.niri.fragments."60-shell-noctalia" = ''
          layer-rule {
              match namespace="^wallpaper$"
              place-within-backdrop true
          }

          layer-rule {
              match namespace="^noctalia-backdrop"
              place-within-backdrop true
          }

          window-rule {
              match app-id="dev.noctalia.Noctalia"
              open-floating true
              default-column-width { fixed 1080; }
              default-window-height { fixed 920; }
          }
        '';
      })
    ]
  );
}
