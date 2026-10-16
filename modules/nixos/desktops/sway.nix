{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.desktop;
  remote = config.my.remoteDesktop.wayvnc;
  user = config.my.user.name;
  rustdesk = config.my.programs.rustdesk;
  headlessBackends = if rustdesk.enable && rustdesk.autoStart then "headless,libinput" else "headless";
  greetdSessionEnvironment = pkgs.writeText "greetd-sway-session-environment" ''
    XDG_SESSION_TYPE DEFAULT=wayland OVERRIDE=wayland
    XDG_SESSION_DESKTOP DEFAULT=sway OVERRIDE=sway
    XDG_CURRENT_DESKTOP DEFAULT=sway OVERRIDE=sway
  '';
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

          extraSessionCommands = ''
            export XDG_SESSION_TYPE=wayland
            export XDG_SESSION_DESKTOP=sway

            # Foot and other user services must receive the session metadata
            # before Sway's config starts the graphical session targets.
            ${pkgs.systemd}/bin/systemctl --user import-environment \
              XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_SESSION_ID || true
          '' + lib.optionalString (remote.enable && remote.headless) ''
            # RustDesk injects kernel input events, which need libinput even
            # when every output is virtual.
            export WLR_BACKENDS=${headlessBackends}
            export WLR_LIBINPUT_NO_DEVICES=1
            export WLR_RENDERER=pixman
          '';
        };
      }

      (lib.mkIf remote.enable {
        # Register the session as Wayland before pam_systemd runs, so
        # RustDesk's system service can discover the correct desktop.
        security.pam.services.greetd.rules.session.sway-environment = {
          order = config.security.pam.services.greetd.rules.session.login.order - 1;
          control = "required";
          modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
          settings = {
            conffile = "${greetdSessionEnvironment}";
            readenv = 0;
          };
        };

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
