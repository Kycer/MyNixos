{ lib, osConfig, ... }:

let
  cfg = osConfig.my.remoteDesktop.wayvnc;
in
{
  config = lib.mkIf cfg.enable {
    services.wayvnc = {
      enable = true;
      autoStart = true;
      systemdTarget = osConfig.my.desktop.session.systemdTarget;

      settings = {
        inherit (cfg) address port;
        enable_auth = false;
      };
    };

    systemd.user.services.wayvnc.Service = {
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
