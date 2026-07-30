{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.my.features.fonts.enable {
    fonts = {
      packages = with pkgs; [
        material-design-icons
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        wqy_microhei
        wqy_zenhei
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
      ];

      fontconfig = {
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [
            "JetBrainsMono Nerd Font Mono"
            "Noto Sans Mono CJK SC"
          ];
          sansSerif = [
            "Noto Sans CJK SC"
            "Noto Sans"
            "Noto Color Emoji"
          ];
          serif = [
            "Noto Serif CJK SC"
            "Noto Serif"
            "Noto Color Emoji"
          ];
        };

        hinting = {
          enable = true;
          autohint = true;
          style = "none";
        };

        subpixel.rgba = "rgb";
        useEmbeddedBitmaps = false;
      };
    };
  };
}
