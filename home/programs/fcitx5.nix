{
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  config = lib.mkIf osConfig.my.programs.fcitx5.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        addons = [
          pkgs.qt6Packages.fcitx5-chinese-addons
          pkgs.qt6Packages.fcitx5-configtool
          (pkgs.fcitx5-rime.override {
            rimeDataPkgs = [ pkgs.rime-ice ];
          })
          pkgs.fcitx5-nord
        ];

        waylandFrontend = true;

        settings = {
          inputMethod = {
            GroupOrder."0" = "Default";

            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "rime";
            };

            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "rime";
          };

          addons.classicui.globalSection.Theme = "Nord-Dark";
        };
      };
    };

    xdg.dataFile."fcitx5/rime/default.custom.yaml".text = ''
      patch:
        __include: rime_ice_suggestion:/
        schema_list:
          - schema: double_pinyin_flypy
    '';
  };
}
