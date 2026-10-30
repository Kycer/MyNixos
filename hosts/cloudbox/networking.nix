{
  config,
  lib,
  ...
}:

{
  services.cloudflared.enable = true;

  # The upstream module creates services for JSON-credential tunnels only.
  # Read the dashboard token at runtime so it never enters the Nix store.
  systemd.services.cloudflared = lib.mkIf config.services.cloudflared.enable {
    description = "Cloudflare Tunnel (dashboard-managed)";
    # Start manually with systemctl; do not start at boot.
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      DynamicUser = true;
      LoadCredential = [ "tunnel-token:/etc/cloudflared/token" ];
      ExecStart = "${lib.getExe config.services.cloudflared.package} tunnel --no-autoupdate run --token-file %d/tunnel-token";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

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
    generatePrivateKeyFile = true;

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
