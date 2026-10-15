{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  sessionTarget = config.wayland.systemd.target;
in
{
  config = lib.mkIf (
    osConfig.my.remoteDesktop.rustdesk.enable && osConfig.my.desktop.session.enable
  ) {
    systemd.user.services.rustdesk = {
      Unit = {
        Description = "RustDesk desktop application";
        After = [ sessionTarget ];
        PartOf = [ sessionTarget ];
      };

      Service = {
        ExecStart = "${pkgs.rustdesk}/bin/rustdesk";
        Restart = "on-failure";
        RestartSec = 3;
      };

      Install.WantedBy = [ sessionTarget ];
    };
  };
}
