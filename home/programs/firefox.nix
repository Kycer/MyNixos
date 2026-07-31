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
      "browser.download.useDownloadDir" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.tabs.closeWindowWithLastTab" = true;
      "browser.theme.content-theme" = 0;
      "browser.theme.toolbar-theme" = 0;
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "intl.locale.requested" = "zh-CN";
      "layout.css.prefers-color-scheme.content-override" = 0;
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.verticalTabs.expanded" = true;
      "sidebar.visibility" = "always-show";
      "browser.profiles.enabled" = true;
      "browser.profiles.grouping.enabled" = true;
      "browser.profiles.showProfileIndicator" = true;
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

        Preferences = {
          "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
          "browser.download.downloadDir" = "${config.home.homeDirectory}/Downloads";
          "browser.download.folderList" = 2;
          "browser.download.useDownloadDir" = false;
          "layout.css.prefers-color-scheme.content-override" = 0;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "always-show";
        };

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

    home.activation.firefoxStartWithLastProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for ini in "${config.home.homeDirectory}/.mozilla/firefox/profiles.ini" "${config.home.homeDirectory}/.config/mozilla/firefox/profiles.ini"; do
        if [ -f "$ini" ]; then
          ${pkgs.gnused}/bin/sed -i 's/StartWithLastProfile=1/StartWithLastProfile=0/' "$ini"
        fi
      done
    '';
  };
}
