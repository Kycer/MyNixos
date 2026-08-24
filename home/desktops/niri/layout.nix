_:

{
  my.niri.fragments."40-layout" = ''
    layout {
        gaps 3
        center-focused-column "never"
        default-column-display "tabbed"
        always-center-single-column

        preset-column-widths {
            proportion 0.5
            proportion 0.96
            proportion 1.0
        }

        preset-window-heights {
            proportion 0.5
            proportion 0.96
            proportion 1.0
        }

        default-column-width { proportion 0.96; }

        focus-ring {
            off
            width 2
            active-gradient from="#d5c4a1" to="#bd93f9" in="oklch" angle=90 relative-to="workspace-view"
            inactive-color "#7c6f64"
        }

        border {
            off
            width 8
            active-color "#ffc87f"
            inactive-color "#585b70"
        }

        tab-indicator {
            hide-when-single-tab
            place-within-column
            gap 5
            width 6
            length total-proportion=1.0
            gaps-between-tabs 2
            corner-radius 8
            active-gradient from="#d5c4a1" to="#bd93f9" in="oklch" angle=90 relative-to="workspace-view"
            inactive-color "#7c6f64"
            urgent-color "blue"
        }

        insert-hint {
            color "#ffc87f80"
        }

        struts {
        }
    }

    overview {
        zoom 0.6
        backdrop-color "#333333"

        workspace-shadow {
            off
            softness 40
            spread 10
            offset x=0 y=10
            color "#00000050"
        }
    }

    recent-windows {
        off
    }
  '';
}
