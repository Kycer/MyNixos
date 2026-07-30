{
  config,
  lib,
  ...
}:

let
  desktop = config.my.desktop;
  remote = config.my.remoteDesktop.wayvnc;
  user = config.my.user.name;
in
{
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !remote.enable || desktop == "sway";
          message = "my.remoteDesktop.wayvnc currently requires my.desktop = \"sway\".";
        }
      ];

      environment.sessionVariables.NIXOS_OZONE_WL =
        lib.mkIf (desktop != "none") "1";
      security.polkit.enable = desktop != "none";
    }

    (lib.mkIf (desktop == "niri") {
      programs.niri.enable = true;
    })

    (lib.mkIf (desktop == "sway") {
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;

        extraSessionCommands = lib.optionalString remote.enable ''
          export WLR_BACKENDS=headless
          export WLR_LIBINPUT_NO_DEVICES=1
          export WLR_RENDERER=pixman
        '';
      };
    })

    (lib.mkIf remote.enable {
      services.greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${config.programs.sway.package}/bin/sway";
            user = user;
          };
          default_session = initial_session;
        };
      };
    })
  ];
}
