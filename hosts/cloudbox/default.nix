{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ]
  ++ lib.optional (builtins.pathExists ./installer.nix) ./installer.nix;

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  my = {
    user = {
      # install.sh writes the deployed login name to ignored installer.nix.
      name = lib.mkDefault "alice";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = "zsh";

      # Public keys are safe to keep in the flake. Never put private keys here.
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEsbDw8qoAfGJTawe6c8Y4XxcHoLtinDOHsmkqCF91JRPbdOjCAzD/aaHFo8SxHvNXG8HZLKg57usY2hcsNk2x989XxcQu9j1TzZrUFAm0IaW9tiCnXbqSU+RpjqDfg0A7jW92kiZ3Jo3ODClkBEWWEGDokuo+SG6QrpZCXBwVzQvuGQUNEHOnCFieSlpdDR3glwBvGdmY6+TXUParSqkhMeG4Iu/DfzIIUW3uuZvfqzt2+WIO9/B6aOYyXlnl6C8XVzejjqup6JXVoyn0B7YaNo/K/WonDgGIFlj/q9AV+GYegIshHbFNJABEW47OtUY8Uq32VcKFyZelw840h8XqQncouQvEuC+zcYhXql0IHkpFyBZ5yzVgr3YxGRx4bYJw66loeA2kbRBIfPhCdW1XWqS5gyfNxGy56LfYyNJj29HHOl969y4nyIo7BPxQeR+9fqO6cbQd8NjDgVZ3XQkeF3lnwJ1fYPZvDZZgm+FTe7MOjk+RCwTtRe3j4n0HCjt3dZcJtCLHgjQr8Old7l4NrM6E9Sg1Ex4b/ILtaC8aIakR0MqrKayC+dYvqdsu0oc2yc3my7g/SLjmxR4/0yv7T8prS9e4PAGPzMK6ipu+CXYR9VL67gj88v7h6v2fyeGF9c/dKwfKQF8N4Ohukl2u6jtL2WA72CzjuEN7W8RcpQ== zz@abc.com"
      ];

      git = {
        # Git identity is independent of the Linux login name.
        name = null;
        # Set this to your real Git email before committing.
        email = null;
        defaultBranch = "main";
      };
    };

    desktop = {
      wm = "sway";
      shellStyle = "custom";
      custom = {
        bar = "waybar";
        launcher = "rofi";
        notification = "swaync";
      };
    };

    features = {
      audio.enable = true;
      fonts.enable = true;
      openssh.enable = true;
      wireguard = {
        enable = true;
        listenPort = 51820;
      };
    };

    programs = {
      fcitx5.enable = true;
      firefox.enable = true;
      git.enable = true;
      neovim.enable = true;
      networkTools.enable = true;
    };

    sudo.passwordlessPowerCommands = true;

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

    # Packages used by this host only can be added here.
    packages = {
      system = with pkgs; [
        gcc
        rustup
        python3
        go
        nodejs_26
        pnpm
      ];

      home = with pkgs; [
        beekeeper-studio
        telegram-desktop
        nautilus
        yazi
      ];
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

  # Keep the value from the first installation. It is independent of nixpkgs.
  system.stateVersion = "26.05";
}
