{ lib, osConfig, ... }:

let
  cfg = osConfig.my.programs.neovim;
in
{
  config = lib.mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
  };
}
