{ inputs, lib, osConfig, pkgs, ... }:

{
  config = lib.mkIf (osConfig.my.desktop.wm == "sway") {
    home.packages = [
      inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
