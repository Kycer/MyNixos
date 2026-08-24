{
  config,
  lib,
  osConfig,
  ...
}:

let
  adapterDirectories = lib.filterAttrs (
    name: type: type == "directory" && builtins.pathExists (./. + "/${name}/default.nix")
  ) (builtins.readDir ./.);
in
{
  # Home desktop adapters are discovered from their directories. A new
  # adapter only needs home/desktops/<name>/default.nix and its matching
  # NixOS adapter; there is no central import list to maintain.
  imports = map (name: ./. + "/${name}") (builtins.attrNames adapterDirectories);

  options.my.desktop.session = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      internal = true;
      description = "Whether a Home Manager desktop adapter is active";
    };

    autostart = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      internal = true;
      description = "Named commands started by the active desktop adapter";
    };

    commandBindings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      internal = true;
      description = "Desktop-neutral key bindings rendered by the active adapter";
    };

    waybar = {
      removeModules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        internal = true;
        description = "Waybar modules removed by the active desktop adapter";
      };

      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        internal = true;
        description = "Waybar settings contributed by the active desktop adapter";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = !osConfig.my.desktop.session.enable || config.my.desktop.session.enable;
        message = "The selected NixOS desktop has no matching Home Manager adapter.";
      }
    ];

    # Services and programs can target the selected session without knowing
    # whether it is implemented by Niri, Sway, or a future compositor.
    wayland.systemd.target = osConfig.my.desktop.session.systemdTarget;
  };
}
