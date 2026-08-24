{
  config,
  lib,
  ...
}:

let
  commandBindings = config.my.desktop.session.commandBindings;
  renderCommand = command: lib.concatMapStringsSep " " builtins.toJSON command;
  bindingNames = lib.sort builtins.lessThan (lib.attrNames commandBindings);
  contributedBindingLines = map (
    key: "        ${key} { spawn ${renderCommand commandBindings.${key}}; }"
  ) bindingNames;
in
{
  my.niri.fragments."70-binds" = ''
        binds {
            Mod+Shift+Slash { show-hotkey-overlay; }

            Mod+Return { spawn "footclient"; }
            Mod+Ctrl+Shift+R { spawn "systemctl" "--user" "restart" "fcitx5-daemon.service"; }
            Mod+Shift+S { spawn "mark-shot"; }

            Mod+E { spawn "footclient" "-e" "yazi"; }
            Mod+Shift+E { spawn "nautilus"; }

            Mod+W { close-window; }
            Mod+Shift+Q { quit; }

            XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"; }
            XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
            XF86AudioMicMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
            XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }

            Mod+H { focus-column-left; }
            Mod+J { focus-window-down; }
            Mod+K { focus-window-up; }
            Mod+L { focus-column-right; }

            Mod+Shift+H { move-column-left; }
            Mod+Shift+J { move-window-down; }
            Mod+Shift+K { move-window-up; }
            Mod+Shift+L { move-column-right; }

            Mod+Home { focus-column-first; }
            Mod+End { focus-column-last; }
            Mod+Shift+Home { move-column-to-first; }
            Mod+Shift+End { move-column-to-last; }

            Mod+Ctrl+H { focus-monitor-left; }
            Mod+Ctrl+J { focus-monitor-down; }
            Mod+Ctrl+K { focus-monitor-up; }
            Mod+Ctrl+L { focus-monitor-right; }

            Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
            Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

            Mod+Tab { focus-window-previous; }
            Mod+Shift+Tab { focus-workspace-previous; }
            Mod+N { focus-workspace-down; }
            Mod+P { focus-workspace-up; }
            Mod+Ctrl+N { move-column-to-workspace-down; }
            Mod+Ctrl+P { move-column-to-workspace-up; }
            Mod+Shift+N { move-workspace-down; }
            Mod+Shift+P { move-workspace-up; }

            Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
            Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }

            Mod+WheelScrollRight { focus-column-right; }
            Mod+WheelScrollLeft { focus-column-left; }
            Mod+Ctrl+WheelScrollRight { move-column-right; }
            Mod+Ctrl+WheelScrollLeft { move-column-left; }

            Mod+Shift+WheelScrollDown { focus-column-right; }
            Mod+Shift+WheelScrollUp { focus-column-left; }
            Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
            Mod+Ctrl+Shift+WheelScrollUp { move-column-left; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }

            Mod+Shift+1 { move-column-to-workspace 1; }
            Mod+Shift+2 { move-column-to-workspace 2; }
            Mod+Shift+3 { move-column-to-workspace 3; }
            Mod+Shift+4 { move-column-to-workspace 4; }
            Mod+Shift+5 { move-column-to-workspace 5; }
            Mod+Shift+6 { move-column-to-workspace 6; }
            Mod+Shift+7 { move-column-to-workspace 7; }
            Mod+Shift+8 { move-column-to-workspace 8; }
            Mod+Shift+9 { move-column-to-workspace 9; }

            Mod+Comma { consume-window-into-column; }
            Mod+Period { expel-window-from-column; }
            Mod+BracketLeft { consume-or-expel-window-left; }
            Mod+BracketRight { consume-or-expel-window-right; }

            Mod+T { toggle-column-tabbed-display; }
            Mod+O { toggle-overview; }
            Mod+R { switch-preset-column-width; }
            Mod+Shift+R { switch-preset-window-height; }
            Mod+Ctrl+R { reset-window-height; }
            Mod+M { maximize-column; }
            Mod+F { fullscreen-window; }
            Mod+Shift+F { toggle-windowed-fullscreen; }
            Mod+Space { toggle-window-floating; }
            Mod+C { switch-focus-between-floating-and-tiling; }

            Mod+Minus { set-column-width "-10%"; }
            Mod+Equal { set-column-width "+10%"; }
            Mod+Shift+Minus { set-window-height "-10%"; }
            Mod+Shift+Equal { set-window-height "+10%"; }

            Mod+Ctrl+Shift+P { power-off-monitors; }

    ${lib.concatStringsSep "\n" contributedBindingLines}
        }
  '';
}
