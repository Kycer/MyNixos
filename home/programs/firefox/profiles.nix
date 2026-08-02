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
      selectionColor = "#cba6f7";
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
      # Reset persisted toolbar customization so the standard LTR order is
      # restored on the next Firefox start.
      "browser.uiCustomization.state" = "";
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.theme.content-theme" = 1;
      "browser.theme.toolbar-theme" = 1;
      "intl.locale.requested" = "zh-CN";
      "layout.css.prefers-color-scheme.content-override" = 2;
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.visibility" = "always-show";
      # Use the traditional profiles.ini/Profile Manager workflow. The newer
      # selectable-profile UI is backed by a separate Firefox-owned database.
      "browser.profiles.enabled" = false;
      "extensions.activeThemeID" = "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}";
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
  };

  wk = commonProfile // {
    id = 1;
    isDefault = false;
    name = "wk";
    path = "wk";
  };

  dv = commonProfile // {
    id = 2;
    isDefault = false;
    name = "dv";
    path = "dv";
  };
}
