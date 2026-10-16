{
  config,
  lib,
  pkgs,
  ...
}:

let
  wayvnc = config.my.remoteDesktop.wayvnc;
  wayvncIsLoopback =
    lib.hasPrefix "127." wayvnc.address
    || builtins.elem wayvnc.address [
      "::1"
      "[::1]"
      "localhost"
    ];
  exposeGlobally = wayvnc.enable && wayvnc.openFirewall && wayvnc.firewallInterface == null;
  exposeOnInterface = wayvnc.enable && wayvnc.openFirewall && wayvnc.firewallInterface != null;
in
{
  assertions = [
    {
      assertion =
        !wayvnc.enable
        || !wayvnc.openFirewall
        || wayvnc.firewallInterface != null
        || wayvncIsLoopback
        || wayvnc.insecureTestMode;
      message = ''
        Unauthenticated WayVNC may only be opened on loopback or a trusted
        firewall interface. Otherwise set insecureTestMode = true explicitly.
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
