{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.programs.rustdesk;
  sessionTarget = config.my.desktop.session.systemdTarget;
in
{
  config = lib.mkIf (cfg.enable && cfg.autoStart) {
    assertions = [
      {
        assertion = config.my.desktop.session.enable;
        message = "my.programs.rustdesk.autoStart requires an active desktop session.";
      }
    ];

    boot.kernelModules = [ "uinput" ];

    # Bind the system service to the primary user's desktop session.
    systemd.user.services.rustdesk = {
      description = "RustDesk desktop session";
      after = [ sessionTarget ];
      partOf = [ sessionTarget ];
      wantedBy = [ sessionTarget ];

      unitConfig = {
        ConditionUser = config.my.user.name;
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.systemd}/bin/systemctl --system start rustdesk.service";
        ExecStop = "${pkgs.systemd}/bin/systemctl --system stop rustdesk.service";
      };
    };

    # RustDesk owns uinput here and launches --server as the desktop user.
    systemd.services.rustdesk = {
      description = "RustDesk input service and desktop server supervisor";
      after = [
        "systemd-logind.service"
        "systemd-modules-load.service"
      ];
      requires = [ "systemd-logind.service" ];

      path = with pkgs; [
        bash
        coreutils
        dbus
        gawk
        glibc.bin
        gnugrep
        gnused
        procps
        sudo
        systemd
        util-linux
      ];

      serviceConfig = {
        User = "root";
        ExecStart = "${pkgs.rustdesk-flutter}/bin/rustdesk --service";
        Restart = "on-failure";
        RestartSec = 3;
        KillMode = "control-group";
      };
    };

    # The user session may only start and stop this specific system unit.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id === "org.freedesktop.systemd1.manage-units"
            && action.lookup("unit") === "rustdesk.service"
            && (action.lookup("verb") === "start" || action.lookup("verb") === "stop")
            && subject.user === ${builtins.toJSON config.my.user.name}) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
