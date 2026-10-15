{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.my.programs.rustdesk;
  sessionTarget = config.wayland.systemd.target;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rustdesk-flutter ];

    assertions = [
      {
        assertion = !cfg.autoStart || osConfig.my.desktop.session.enable;
        message = "my.programs.rustdesk.autoStart requires an active desktop session.";
      }
    ];

    systemd.user.services.rustdesk = lib.mkIf cfg.autoStart {
      Unit = {
        Description = "RustDesk desktop server";
        After = [ sessionTarget ];
        PartOf = [ sessionTarget ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        # The server process makes RustDesk use ScreenCast, which wlr supports.
        ExecStart = "${pkgs.rustdesk-flutter}/bin/rustdesk --server";
        Restart = "on-failure";
        RestartSec = 3;
      };

      Install.WantedBy = [ sessionTarget ];
    };
  };
}
