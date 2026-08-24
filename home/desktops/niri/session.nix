_:

{
  my.niri.fragments."10-session" = ''
    prefer-no-csd

    hotkey-overlay {
        skip-at-startup
    }

    xwayland-satellite {
        path "xwayland-satellite"
    }

    environment {
        _JAVA_AWT_WM_NONREPARENTING "1"
        QT_QPA_PLATFORMTHEME "qt6ct"
        XCURSOR_SIZE "28"

        XMODIFIERS "@im=fcitx"
        QT_IM_MODULE "fcitx"
        SDL_IM_MODULE "fcitx"

        ELECTRON_OZONE_PLATFORM_HINT "auto"

        LANG "zh_CN.UTF-8"
        LANGUAGE "zh_CN:en_US"
        LC_CTYPE "en_US.UTF-8"

        EDITOR "nvim"
    }

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
    }
  '';
}
