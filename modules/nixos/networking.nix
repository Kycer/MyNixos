{ config, lib, pkgs, ... }:

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

  environment.systemPackages = lib.optionals config.my.features.wireguard.enable [
    pkgs.wireguard-tools
  ];

  networking.wg-quick.interfaces = lib.mkIf config.my.features.wireguard.enable {
    wg0 = {
      address = [ "10.10.0.2/24" ];
      mtu = 1380;
      listenPort = config.my.features.wireguard.listenPort;
      privateKeyFile = "/etc/wireguard/private.key";

      peers = [
        {
          publicKey = "RfF2//z3+UR1NAzQmDzMYmG0q5COPGIj9RMi0iH3nFc=";
          allowedIPs = [ "10.10.0.3/32" ];
          # endpoint = "vpn.example.com:51820";
          persistentKeepalive = 25;
        }
        {
          publicKey = "BEBe5n6/JQRL3wC/5HjKusGT4H4MQsvWm6L38MbKEQ4=";
          allowedIPs = [ "10.10.0.5/32" "10.20.0.0/24" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = lib.optionals (
    config.my.features.wireguard.enable && config.my.features.wireguard.openFirewall
  ) [ config.my.features.wireguard.listenPort ];

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
