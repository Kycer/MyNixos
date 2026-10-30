{ pkgs, ... }:

{
  # Packages used by this host only can be added here.
  my.packages.system = with pkgs; [
    cloudflared
  ];

  my.packages.home = with pkgs; [
    telegram-desktop
    nautilus
    yazi
  ];
}
