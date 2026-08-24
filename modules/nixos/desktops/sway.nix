{
  config,
  lib,
  ...
}:

let
  cfg = config.my.desktop;
  remote = config.my.remoteDesktop.wayvnc;
  user = config.my.user.name;
in
{
  config = lib.mkIf (cfg.wm == "sway") (
    lib.mkMerge [
      {
        my.desktop.session = {
          enable = true;
          systemdTarget = "sway-session.target";
          capabilities = [ "wayvnc" ];
        };

        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;

          extraSessionCommands = lib.optionalString (remote.enable && remote.headless) ''
            export WLR_BACKENDS=headless
            export WLR_LIBINPUT_NO_DEVICES=1
            export WLR_RENDERER=pixman
          '';
        };
      }

      (lib.mkIf remote.enable {
        services.greetd = {
          enable = true;
          settings = rec {
            initial_session = {
              command = "${config.programs.sway.package}/bin/sway";
              inherit user;
            };
            default_session = initial_session;
          };
        };
      })
    ]
  );
}
