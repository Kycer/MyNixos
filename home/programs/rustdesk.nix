{
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  config = lib.mkIf osConfig.my.programs.rustdesk.enable {
    home.packages = [ pkgs.rustdesk-flutter ];
  };
}
