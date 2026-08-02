{
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

    "addon@darkreader.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
      installation_mode = "force_installed";
    };

    # Official Catppuccin Mocha theme with Lavender accent.
    "{8446b178-c865-4f5c-8ccc-1d7887811ae3}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-lavender-git/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
