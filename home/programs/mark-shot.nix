{
  lib,
  nurPkgs,
  osConfig,
  pkgs,
  ...
}:

{
  config = lib.mkIf osConfig.my.desktop.session.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "mark-shot" ''
        export XDG_SESSION_TYPE=wayland
        exec ${lib.getExe' nurPkgs.mark-shot "mark-shot"} "$@"
      '')
    ];
  };
}
