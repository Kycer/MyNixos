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
        "en-US"
        "zh-CN"
      ];

      policies = {
        DisableTelemetry = true;
      };

      profiles.default = {
        id = 0;
        isDefault = true;

        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";
        };

        settings = {
          "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
          "browser.download.useDownloadDir" = true;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.tabs.closeWindowWithLastTab" = false;
        };
      };
    };
  };
}
