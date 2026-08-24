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
      inherit (cfg) package;

      languagePacks = [
        "zh-CN"
      ];

      policies = import ./policies.nix;
      profiles = import ./profiles.nix { inherit config; };
    };

    # Use Firefox's traditional profile manager at startup. Home Manager's
    # generated profiles.ini defaults to the last profile, so provide the
    # classic StartWithLastProfile=0 setting explicitly.
    home.file."${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/mozilla/firefox/profiles.ini" =
      {
        force = true;
        # Home Manager also generates this file. Override that exact value;
        # home.file.force only controls replacement on disk and is not a Nix
        # module priority override.
        text = lib.mkForce ''
          [General]
          StartWithLastProfile=0
          Version=2

          [Profile0]
          Name=me
          IsRelative=1
          Path=me
          Default=1

          [Profile1]
          Name=wk
          IsRelative=1
          Path=wk

          [Profile2]
          Name=dv
          IsRelative=1
          Path=dv
        '';
      };
  };
}
