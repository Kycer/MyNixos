{
  lib,
  osConfig,
  ...
}:

let
  cfg = osConfig.my.remoteDesktop.wayvnc;
in
{
  config = lib.mkIf cfg.enable {
    services.wayvnc = {
      enable = true;
      autoStart = true;
      systemdTarget = "sway-session.target";

      settings = {
        address = cfg.address;
        port = cfg.port;
        enable_auth = false;
      };
    };

    systemd.user.services.wayvnc.Service = {
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
