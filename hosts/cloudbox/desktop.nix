{
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
    };
  };
}
