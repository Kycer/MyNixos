{ config, lib, ... }:

let
  wayvnc = config.my.remoteDesktop.wayvnc;
  exposeGlobally =
    wayvnc.enable
    && wayvnc.openFirewall
    && wayvnc.firewallInterface == null;
  exposeOnInterface =
    wayvnc.enable
    && wayvnc.openFirewall
    && wayvnc.firewallInterface != null;
in
{
  assertions = [
    {
      assertion =
        !(wayvnc.address == "0.0.0.0" && wayvnc.openFirewall)
        || wayvnc.insecureTestMode;
      message = ''
        Public WayVNC exposure requires
        my.remoteDesktop.wayvnc.insecureTestMode = true.
      '';
    }
  ];

  warnings = lib.optional wayvnc.insecureTestMode ''
    WayVNC is exposed without authentication or transport encryption.
    Use only for temporary testing, then bind it to a WireGuard address/interface.
  '';

  networking.firewall = {
    enable = true;
    allowedTCPPorts = lib.optionals exposeGlobally [ wayvnc.port ];
    interfaces = lib.optionalAttrs exposeOnInterface {
      ${wayvnc.firewallInterface}.allowedTCPPorts = [ wayvnc.port ];
    };
  };

  programs.mtr.enable = config.my.programs.networkTools.enable;

  services.openssh = lib.mkIf config.my.features.openssh.enable {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
