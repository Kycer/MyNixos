{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./user.nix
    ./desktop.nix
    ./flatpak.nix
    ./networking.nix
    ./packages.nix
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
    features.openssh.enable = true;
    sudo.passwordlessPowerCommands = true;
  };

  # Keep the value from the first installation. It is independent of nixpkgs.
  system.stateVersion = "26.05";
}
