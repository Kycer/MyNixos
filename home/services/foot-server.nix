{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  graphicalDesktop = osConfig.my.desktop != "none";
  systemdTarget =
    if osConfig.my.desktop == "sway" then
      "sway-session.target"
    else
      "graphical-session.target";
in
{
  config = lib.mkIf graphicalDesktop {
    systemd.user.services.foot-server = {
      Unit = {
        Description = "Foot terminal server";
        PartOf = [ systemdTarget ];
        After = [ systemdTarget ];
      };

      Service = {
        ExecStart = "${pkgs.foot}/bin/foot --server";
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = [ systemdTarget ];
    };
  };
}
