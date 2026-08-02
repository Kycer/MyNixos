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

    # Official Catppuccin Mocha theme with Mauve accent.
    "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-mauve-git/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
