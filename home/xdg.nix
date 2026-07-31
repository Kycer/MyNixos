{ config, ... }:

{
  xdg.configFile = {
    # `just -g <recipe>` uses this file from any working directory.
    "just/justfile".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/justfile";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    download = "${config.home.homeDirectory}/Downloads";
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
  };
}
