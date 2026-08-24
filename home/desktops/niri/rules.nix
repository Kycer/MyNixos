_:

{
  my.niri.fragments."50-rules" = ''
    window-rule {
        geometry-corner-radius 8
        clip-to-geometry true
    }

    window-rule {
        match is-active=true
        opacity 0.90
        draw-border-with-background false

        background-effect {
            blur true
        }

        popups {
            geometry-corner-radius 15
            opacity 1.0

            background-effect {
                blur true
            }
        }
    }

    window-rule {
        match is-active=false
        opacity 0.95

        background-effect {
            blur true
        }
    }

    window-rule {
        match app-id="firefox"
        match app-id="zen-browser"
        match app-id="brave-browser"
        match app-id="google-chrome"
        match app-id="code"
        match app-id="wechat"
        match app-id="Vncviewer"
        match app-id="xfreerdp"
        match app-id="jetbrains-idea"
        match app-id="jetbrains-datagrip"
        match app-id="org.wezfurlong.kitty"
        match app-id="vivaldi-stable"

        default-column-width { proportion 0.96; }
    }

    window-rule {
        match title="微信"
        match title="预览"
        match app-id="Sxiv"
        open-floating true

        shadow {
            on
        }
    }
  '';
}
