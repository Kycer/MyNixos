{ pkgs, ... }:

{
  # Packages used by this host only can be added here.
  my.packages = {
    system = with pkgs; [
      gcc
      rustup
      python3
      go
      nodejs_26
      pnpm
    ];

    home = with pkgs; [
      telegram-desktop
      nautilus
      yazi
    ];
  };
}
