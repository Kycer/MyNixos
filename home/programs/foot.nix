{ config, ... }:

{
  xdg.configFile."foot".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.nixos/home/programs/foot";
}
