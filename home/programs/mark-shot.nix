{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  markShot = inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  config = lib.mkIf osConfig.my.desktop.session.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "mark-shot" ''
        export XDG_SESSION_TYPE=wayland
        exec ${lib.getExe' markShot "mark-shot"} "$@"
      '')
    ];
  };
}
