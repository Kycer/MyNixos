{ lib, ... }:

{
  imports = [
    (
      if builtins.pathExists ./hardware-configuration.nix then
        ./hardware-configuration.nix
      else
        throw "Missing cloudbox hardware configuration. Run install.sh or copy this machine's hardware-configuration.nix into hosts/cloudbox/."
    )
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
