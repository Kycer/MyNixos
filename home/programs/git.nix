{ lib, osConfig, ... }:

let
  cfg = osConfig.my.user.git;
in
{
  config = lib.mkIf osConfig.my.programs.git.enable {
    programs.git = {
      enable = true;

      settings =
        {
          init.defaultBranch = cfg.defaultBranch;
          pull.rebase = false;
        }
        // lib.optionalAttrs (cfg.name != null || cfg.email != null) {
          user =
            lib.optionalAttrs (cfg.name != null) { name = cfg.name; }
            // lib.optionalAttrs (cfg.email != null) { email = cfg.email; };
        };
    };
  };
}
