{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.my.desktop;
  remote = osConfig.my.remoteDesktop.wayvnc;
  session = config.my.desktop.session;
  modifier = "Mod1";

  normalizeToken =
    token:
    if token == "Mod" then
      modifier
    else if modifier == "Mod1" && token == "Alt" then
      # Mod1 is Alt in this adapter. Map the desktop-neutral secondary
      # modifier to Ctrl so combinations remain usable.
      "Ctrl"
    else if builtins.stringLength token == 1 then
      lib.toLower token
    else
      token;
  toSwayKey = key: lib.concatMapStringsSep "+" normalizeToken (lib.splitString "+" key);
  toExec = command: "exec ${lib.escapeShellArgs command}";

  contributedBindings = lib.mapAttrs' (
    key: command: lib.nameValuePair (toSwayKey key) (toExec command)
  ) session.commandBindings;
  startupNames = lib.sort builtins.lessThan (lib.attrNames session.autostart);
  startup = map (name: { command = lib.escapeShellArgs session.autostart.${name}; }) startupNames;

  workspaceBindings = lib.listToAttrs (
    lib.concatMap (
      number:
      let
        workspace = toString number;
      in
      [
        (lib.nameValuePair "${modifier}+${workspace}" "workspace number ${workspace}")
        (lib.nameValuePair "${modifier}+Shift+${workspace}" "move container to workspace number ${workspace}")
      ]
    ) (lib.range 1 9)
  );

  baseBindings = {
    "${modifier}+Return" = "exec footclient";
    "${modifier}+Ctrl+Shift+r" = "exec systemctl --user restart fcitx5-daemon.service";
    "${modifier}+Shift+s" = "exec mark-shot";
    "${modifier}+e" = "exec footclient -e yazi";
    "${modifier}+Shift+e" = "exec nautilus";
    "${modifier}+w" = "kill";
    "${modifier}+Shift+q" = "exec swaynag -t warning -m 'Exit Sway?' -B 'Exit' 'swaymsg exit'";

    "--locked XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+";
    "--locked XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
    "--locked XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    "--locked XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    "--locked XF86MonBrightnessUp" = "exec brightnessctl set +5%";
    "--locked XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

    "${modifier}+h" = "focus left";
    "${modifier}+j" = "focus down";
    "${modifier}+k" = "focus up";
    "${modifier}+l" = "focus right";
    "${modifier}+Shift+h" = "move left";
    "${modifier}+Shift+j" = "move down";
    "${modifier}+Shift+k" = "move up";
    "${modifier}+Shift+l" = "move right";

    "${modifier}+Ctrl+h" = "focus output left";
    "${modifier}+Ctrl+j" = "focus output down";
    "${modifier}+Ctrl+k" = "focus output up";
    "${modifier}+Ctrl+l" = "focus output right";
    "${modifier}+Ctrl+Shift+h" = "move container to output left";
    "${modifier}+Ctrl+Shift+j" = "move container to output down";
    "${modifier}+Ctrl+Shift+k" = "move container to output up";
    "${modifier}+Ctrl+Shift+l" = "move container to output right";

    "${modifier}+Tab" = "focus prev";
    "${modifier}+Shift+Tab" = "workspace back_and_forth";
    "${modifier}+n" = "workspace next";
    "${modifier}+p" = "workspace prev";
    "${modifier}+Ctrl+n" = "move container to workspace next";
    "${modifier}+Ctrl+p" = "move container to workspace prev";

    "--whole-window ${modifier}+button5" = "workspace next";
    "--whole-window ${modifier}+button4" = "workspace prev";
    "--whole-window ${modifier}+Ctrl+button5" = "move container to workspace next";
    "--whole-window ${modifier}+Ctrl+button4" = "move container to workspace prev";

    "${modifier}+t" = "layout toggle tabbed split";
    "${modifier}+f" = "fullscreen toggle";
    "${modifier}+space" = "floating toggle";
    "${modifier}+c" = "focus mode_toggle";
    "${modifier}+minus" = "resize shrink width 10 ppt";
    "${modifier}+equal" = "resize grow width 10 ppt";
    "${modifier}+Shift+minus" = "resize shrink height 10 ppt";
    "${modifier}+Shift+equal" = "resize grow height 10 ppt";
    "${modifier}+Ctrl+Shift+p" = "output * power toggle";
    "${modifier}+Shift+c" = "reload";
  };

  color = border: background: text: {
    inherit border background text;
    indicator = border;
    childBorder = border;
  };
in
{
  config = lib.mkIf (cfg.wm == "sway") {
    my.desktop.session = {
      enable = true;
      commandBindings."Mod+Shift+X" = lib.mkDefault [ "swaylock" ];
    };

    home.packages = with pkgs; [
      brightnessctl
      swaylock
    ];

    wayland.windowManager.sway = {
      enable = true;
      package = null;
      systemd.enable = true;
      extraConfigEarly = ''
        include /etc/sway/config.d/*
      '';

      config = {
        inherit modifier startup;
        terminal = "footclient";
        menu = "rofi -show drun";
        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 14.0;
        };
        floating.modifier = modifier;
        workspaceAutoBackAndForth = true;
        window = {
          border = 2;
          titlebar = false;
        };
        gaps = {
          inner = 4;
          outer = 2;
        };
        bars = [ ];
        modes = { };

        keybindings = lib.mkForce (baseBindings // workspaceBindings // contributedBindings);

        colors = {
          focused = color "#c6a0f6" "#c6a0f6" "#24273a";
          focusedInactive = color "#363a4f" "#363a4f" "#cad3f5";
          unfocused = color "#1e2030" "#1e2030" "#cad3f5";
          urgent = color "#ed8796" "#ed8796" "#24273a";
        };

        output = lib.optionalAttrs (remote.enable && remote.headless) {
          "HEADLESS-1" = {
            mode = remote.resolution;
            scale = "1";
          };
        };
      };
    };
  };
}
