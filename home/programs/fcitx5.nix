{
  config,
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
          # Needed by GTK/XWayland applications such as Firefox. Native
          # Wayland applications still use the Wayland text-input protocol.
          pkgs.fcitx5-gtk
          pkgs.qt6Packages.fcitx5-chinese-addons
          pkgs.qt6Packages.fcitx5-configtool
          (pkgs.fcitx5-rime.override {
            rimeDataPkgs = [ pkgs.rime-ice ];
          })
          pkgs.fcitx5-nord
        ];

        waylandFrontend = true;

        settings = {
          # Keep the current Arch configuration: do not provide additional
          # input-method cycling shortcuts and disable TogglePreedit.
          globalOptions.Hotkey = {
            EnumerateForwardKeys = "";
            EnumerateBackwardKeys = "";
            TogglePreedit = "";
          };

          inputMethod = {
            GroupOrder."0" = "Default";

            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "rime";
            };

            "Groups/0/Items/0".Name = "rime";
          };

          addons = {
            classicui.globalSection = {
              Theme = "Nord-Dark";
              DarkTheme = "Nord-Dark";
            };

            # These shortcuts are intentionally empty in the current Arch
            # configuration.
            chttrans.globalSection.Hotkey = "";

            clipboard.globalSection = {
              TriggerKey = "";
              PastePrimaryKey = "";
            };

            cloudpinyin.globalSection."Toggle Key" = "";
            keyboard.globalSection = {
              "Hint Trigger" = "";
              "One Time Hint Trigger" = "";
            };
            pinyin.globalSection = {
              SecondCandidate = "";
              ThirdCandidate = "";
            };
            punctuation.globalSection.Hotkey = "";
            quickphrase.globalSection.TriggerKey = "";
            table.globalSection = {
              ModifyDictionaryKey = "";
              ForgetWord = "";
              LookupPinyinKey = "";
            };
            unicode.globalSection = {
              TriggerKey = "";
              DirectUnicodeMode = "";
            };
          };
        };
      };
    };

    # Replace an older user profile so the removed keyboard-us entry does not
    # survive in ~/.config/fcitx5/profile.
    xdg.configFile."fcitx5/profile".force = true;

    xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
      force = true;
      text = ''
        patch:
          __include: rime_ice_suggestion:/
          schema_list:
            - schema: double_pinyin_flypy
      '';
    };

    xdg.dataFile."fcitx5/rime/double_pinyin_flypy.custom.yaml" = {
      force = true;
      text = ''
        patch:
          # Rime-Ice exposes this as the 简/繁 switch. Keep simplified Chinese
          # as the default even if an old user profile persisted the option.
          switches/@2/reset: 0
      '';
    };

    # Remove obsolete user-level Rime configuration. Old luna_pinyin schemas
    # can reference luna_pinyin.dict.yaml, which is not part of Rime-Ice.
    # Keep user dictionaries intact; build is generated cache data.
    home.activation.rimeIceCleanup = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      rime_dir="${config.xdg.dataHome}/fcitx5/rime"

      if [ -d "$rime_dir" ]; then
        rm -f -- \
          "$rime_dir/default.yaml" \
          "$rime_dir/luna_pinyin.schema.yaml" \
          "$rime_dir/luna_pinyin.custom.yaml"
        rm -rf -- "$rime_dir/build"
      fi
    '';
  };
}
