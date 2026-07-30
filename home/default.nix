{
  imports = [
    ./config-files.nix
    ./desktops
    ./packages.nix
    ./programs
    ./services
    ./themes.nix
  ];

  programs.home-manager.enable = true;
}
