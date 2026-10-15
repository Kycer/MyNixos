{ pkgs, ... }:

{
  # Packages used by this host only can be added here.
  my.packages.home = with pkgs; [
    telegram-desktop
    nautilus
    rustdesk
    yazi
  ];
}
