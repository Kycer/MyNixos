{
  # Temporary backport for the duplicate-frame crash in xdpw 0.8.4.
  # https://github.com/emersion/xdg-desktop-portal-wlr/pull/405
  nixpkgs.overlays = [
    (_final: prev: {
      xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          ./patches/xdg-desktop-portal-wlr-destroy-stale-frame.patch
        ];
      });
    })
  ];

  my = {
    desktop = {
      wm = "sway";
      shellStyle = "custom";
      custom = {
        bar = "waybar";
        launcher = "rofi";
        notification = "swaync";
      };
    };

    features = {
      audio.enable = true;
      fonts.enable = true;
    };

    programs = {
      fcitx5.enable = true;
      firefox.enable = true;
      git.enable = true;
      neovim.enable = true;
      networkTools.enable = true;
      rustdesk = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
