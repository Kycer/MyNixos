{ lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.my = {
    user = {
      name = mkOption {
        type = types.str;
        description = "Primary local user name";
      };

      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ "wheel" ];
        description = "Extra groups for the primary user";
      };

      authorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "SSH public keys for the primary user";
      };

      shell = mkOption {
        type = types.enum [
          "bash"
          "zsh"
        ];
        default = "zsh";
        description = "Login shell for the primary user";
      };

      git = {
        name = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Git author name";
        };

        email = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Git author email";
        };

        defaultBranch = mkOption {
          type = types.str;
          default = "main";
          description = "Default branch for new Git repositories";
        };
      };
    };

    desktop = {
      wm = mkOption {
        type = types.enum [
          "none"
          "niri"
          "sway"
        ];
        default = "none";
        description = "Desktop environment/WM enabled on this host";
      };

      shellStyle = mkOption {
        type = types.enum [
          "noctalia-shell"
          "custom"
        ];
        default = "noctalia-shell";
        description = "Desktop shell style: 'noctalia-shell' (All-in-One) or 'custom' (Modular Waybar/Rofi)";
      };

      custom = {
        bar = mkOption {
          type = types.enum [ "waybar" "none" ];
          default = "waybar";
          description = "Status bar component when shellStyle == 'custom'";
        };

        launcher = mkOption {
          type = types.enum [ "rofi" "fuzzel" "none" ];
          default = "rofi";
          description = "Launcher component when shellStyle == 'custom'";
        };

        notification = mkOption {
          type = types.enum [ "swaync" "dunst" "none" ];
          default = "swaync";
          description = "Notification daemon when shellStyle == 'custom'";
        };
      };
    };

    theme = {
      gtkTheme = {
        name = mkOption {
          type = types.str;
          default = "catppuccin-macchiato-lavender-standard";
          description = "GTK theme name";
        };
        package = mkOption {
          type = types.package;
          default = pkgs.catppuccin-gtk.override {
            accents = [ "lavender" ];
            variant = "macchiato";
          };
          description = "GTK theme package to install";
        };
      };

      iconTheme = {
        name = mkOption {
          type = types.str;
          default = "Papirus-Dark";
          description = "Icon theme name";
        };
        package = mkOption {
          type = types.package;
          default = pkgs.papirus-icon-theme;
          description = "Icon theme package to install";
        };
      };

      cursor = {
        name = mkOption {
          type = types.str;
          default = "Bibata-Modern-Classic";
          description = "Cursor theme name";
        };
        size = mkOption {
          type = types.int;
          default = 28;
          description = "Cursor theme size";
        };
        package = mkOption {
          type = types.package;
          default = pkgs.bibata-cursors;
          description = "Cursor theme package to install";
        };
      };

      font = {
        name = mkOption {
          type = types.str;
          default = "WenQuanYi Micro Hei Mono";
          description = "Interface font name";
        };
        size = mkOption {
          type = types.int;
          default = 16;
          description = "Interface font size";
        };
      };
    };

    features = {
      audio.enable = mkEnableOption "PipeWire audio";
      fonts.enable = mkEnableOption "the shared font collection";
      openssh.enable = mkEnableOption "the OpenSSH server";

      wireguard = {
        enable = mkEnableOption "WireGuard VPN 服务与诊断工具";
        listenPort = mkOption {
          type = types.port;
          default = 51820;
          description = "WireGuard UDP 监听端口";
        };
        openFirewall = mkOption {
          type = types.bool;
          default = true;
          description = "是否在 NixOS 防火墙中自动开放 WireGuard UDP 监听端口";
        };
      };
    };

    programs = {
      fcitx5.enable = mkEnableOption "Fcitx5 user configuration";

      firefox = {
        enable = mkEnableOption "Firefox user configuration";
        package = mkOption {
          type = types.package;
          default = pkgs.firefox;
          defaultText = lib.literalExpression "pkgs.firefox";
          description = "Firefox package installed by Home Manager";
        };
      };

      git.enable = mkEnableOption "Git user configuration";

      neovim = {
        enable = mkEnableOption "Neovim user configuration";
        package = mkOption {
          type = types.package;
          default = pkgs.neovim;
          defaultText = lib.literalExpression "pkgs.neovim";
          description = "Neovim package installed by Home Manager";
        };
      };

      networkTools.enable = mkEnableOption "user network diagnostic tools";
    };

    sudo.passwordlessPowerCommands = mkOption {
      type = types.bool;
      default = false;
      description = "Allow wheel to suspend, reboot, and power off without a password";
    };

    remoteDesktop.wayvnc = {
      enable = mkEnableOption "a WayVNC remote desktop";

      headless = mkOption {
        type = types.bool;
        default = false;
        description = "Run Sway in headless virtual display mode (for cloud servers without physical monitors)";
      };

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address on which WayVNC listens";
      };

      port = mkOption {
        type = types.port;
        default = 5900;
        description = "TCP port on which WayVNC listens";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open the configured WayVNC port in the NixOS firewall";
      };

      firewallInterface = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Limit the WayVNC firewall rule to an interface such as wg0";
      };

      insecureTestMode = mkOption {
        type = types.bool;
        default = false;
        description = "Acknowledge unauthenticated WayVNC exposure during temporary testing";
      };

      resolution = mkOption {
        type = types.str;
        default = "1920x1080";
        description = "Resolution of the headless Sway output";
      };
    };

    packages = {
      system = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Additional packages installed system-wide on this host";
      };

      home = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Additional packages installed for the primary user on this host";
      };
    };
  };
}
