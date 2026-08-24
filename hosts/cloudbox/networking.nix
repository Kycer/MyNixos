{
  config,
  lib,
  ...
}:

{
  my = {
    features.wireguard = {
      enable = true;
      listenPort = 51820;
    };

    remoteDesktop.wayvnc = {
      enable = true;
      headless = true;
      address = "10.10.0.2";
      port = 5900;
      openFirewall = true;
      firewallInterface = "wg0";

      # WayVNC has no built-in auth here; exposure is limited to WireGuard.
      insecureTestMode = false;
    };
  };

  # WireGuard identity and peers are specific to this host; the reusable
  # networking module only handles tooling and firewall policy.
  networking.wg-quick.interfaces.wg0 = lib.mkIf config.my.features.wireguard.enable {
    address = [ "10.10.0.2/24" ];
    mtu = 1380;
    listenPort = config.my.features.wireguard.listenPort;
    privateKeyFile = "/etc/wireguard/private.key";

    peers = [
      {
        publicKey = "RfF2//z3+UR1NAzQmDzMYmG0q5COPGIj9RMi0iH3nFc=";
        allowedIPs = [ "10.10.0.3/32" ];
        persistentKeepalive = 25;
      }
      {
        publicKey = "BEBe5n6/JQRL3wC/5HjKusGT4H4MQsvWm6L38MbKEQ4=";
        allowedIPs = [
          "10.10.0.5/32"
          "10.20.0.0/24"
        ];
        persistentKeepalive = 25;
      }
    ];
  };
}
