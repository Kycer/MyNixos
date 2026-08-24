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
  config = lib.mkIf osConfig.my.desktop.session.enable {
    systemd.user.services.polkit-gnome-authentication-agent = {
      Unit = {
        Description = "GNOME PolicyKit authentication agent";
        After = [ sessionTarget ];
        PartOf = [ sessionTarget ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = [ sessionTarget ];
    };
  };
}
