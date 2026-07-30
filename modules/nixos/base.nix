{ config, lib, ... }:

{
  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = config.my.packages.system;

  security.rtkit.enable = config.my.features.audio.enable;
  services.pipewire = lib.mkIf config.my.features.audio.enable {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}
