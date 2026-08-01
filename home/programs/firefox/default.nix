{
  config,
  lib,
  osConfig,
  ...
}:

let
  cfg = osConfig.my.programs.firefox;
in
{
  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = cfg.package;

      languagePacks = [
        "zh-CN"
      ];

      policies = import ./policies.nix;
      profiles = import ./profiles.nix { inherit config; };
    };

    # Firefox 138+ rewrites profiles.ini when its selectable-profile database
    # changes. Home Manager normally links this file to the read-only
    # generation, so the next activation would report the rewritten file as a
    # collision. Force the link to be recreated on every activation.
    home.file."${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/mozilla/firefox/profiles.ini".force = true;
  };
}
