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

      policies = {
        DisableTelemetry = true;
        RequestedLocales = [ "zh-CN" ];

        ExtensionSettings = {
          "adguardadblocker@adguard.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/adguard-adblocker/latest.xpi";
            installation_mode = "force_installed";
          };

          "vimium-c@gdh1995.cn" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };

      profiles.default = {
        id = 0;
        isDefault = true;

        search = {
          force = true;
          default = "google";
          privateDefault = "google";
        };

        settings = {
          "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
          "browser.download.useDownloadDir" = true;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.tabs.closeWindowWithLastTab" = true;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "intl.locale.requested" = "zh-CN";
          "layout.css.prefers-color-scheme.content-override" = 0;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "always-show";
        };
      };
    };
  };
}
