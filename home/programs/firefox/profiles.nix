{ config }:

let
  darkReaderSettings = {
    schemeVersion = 2;
    enabled = true;
    enabledByDefault = true;
    syncSettings = false;
    syncSitesFixes = false;
    theme = {
      mode = 1;
      brightness = 100;
      contrast = 100;
      grayscale = 0;
      sepia = 0;
      useFont = false;
      fontFamily = "Open Sans";
      textStroke = 0;
      engine = "dynamicTheme";
      stylesheet = "";
      darkSchemeBackgroundColor = "#1e1e2e";
      darkSchemeTextColor = "#cdd6f4";
      lightSchemeBackgroundColor = "#eff1f5";
      lightSchemeTextColor = "#4c4f69";
      scrollbarColor = "#585b70";
      selectionColor = "#585b70";
      styleSystemControls = true;
      lightColorScheme = "Catppuccin";
      darkColorScheme = "Catppuccin";
      immediateModify = false;
    };
  };

  commonProfile = {
    search = {
      force = true;
      default = "google";
      privateDefault = "google";
    };

    settings = {
      "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
      "browser.download.folderList" = 2;
      "browser.download.useDownloadDir" = true;
      "browser.download.alwaysOpenPanel" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.tabs.closeWindowWithLastTab" = true;
      "browser.theme.content-theme" = 1;
      "browser.theme.toolbar-theme" = 1;
      "intl.locale.requested" = "zh-CN";
      "layout.css.prefers-color-scheme.content-override" = 2;
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.visibility" = "always-show";
      "browser.profiles.enabled" = true;
      "browser.profiles.created" = true;
      "browser.profiles.grouping.enabled" = true;
      "browser.profiles.profile-management" = true;
      "browser.profiles.showProfileIndicator" = true;
      "extensions.activeThemeID" = "{8446b178-c865-4f5c-8ccc-1d7887811ae3}";
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };

    userChrome = ./userChrome.css;

    extensions = {
      force = true;
      settings."addon@darkreader.org" = {
        force = true;
        settings = darkReaderSettings;
      };
    };
  };
in
{
  me = commonProfile // {
    id = 0;
    isDefault = true;
    name = "me";
    path = "me";
    storeId = "a1b2c3d4";
  };

  wk = commonProfile // {
    id = 1;
    isDefault = false;
    name = "wk";
    path = "wk";
    storeId = "b2c3d4e5";
  };

  dv = commonProfile // {
    id = 2;
    isDefault = false;
    name = "dv";
    path = "dv";
    storeId = "c3d4e5f6";
  };
}
