{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.my.programs.firefox;

  commonProfile = {
    search = {
      force = true;
      default = "google";
      privateDefault = "google";
    };

    settings = {
      "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
      "browser.download.downloadDir" = "${config.home.homeDirectory}/Downloads";
      "browser.download.folderList" = 2;
      "browser.download.useDownloadDir" = true;
      "browser.download.alwaysOpenPanel" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.topSitesRows" = 0;
      "browser.tabs.closeWindowWithLastTab" = true;
      "browser.theme.content-theme" = 1;
      "browser.theme.toolbar-theme" = 1;
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "intl.locale.requested" = "zh-CN";
      "layout.css.prefers-color-scheme.content-override" = 2;
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.verticalTabs.expanded" = true;
      "sidebar.visibility" = "always-show";
      "browser.profiles.enabled" = true;
      "browser.profiles.grouping.enabled" = true;
      "browser.profiles.profile-management" = true;
      "browser.profiles.showProfileIndicator" = true;
      "browser.profiles.created" = true;
    };
  };
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

      profiles = {
        me = commonProfile // {
          id = 0;
          isDefault = true;
          name = "me";
        };

        wk = commonProfile // {
          id = 1;
          isDefault = false;
          name = "wk";
        };

        dv = commonProfile // {
          id = 2;
          isDefault = false;
          name = "dv";
        };
      };
    };
  };
}
