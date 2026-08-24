{
  config,
  configRoot,
  lib,
  osConfig,
  ...
}:

let
  cfg = osConfig.my.programs.neovim;
in
{
  config = lib.mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

    xdg.configFile = {
      "nvim/init.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${configRoot}/home/programs/nvim/init.lua";
      "nvim/lazy-lock.json".source =
        config.lib.file.mkOutOfStoreSymlink "${configRoot}/home/programs/nvim/lazy-lock.json";
      "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${configRoot}/home/programs/nvim/lua";
      "nvim/stylua.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${configRoot}/home/programs/nvim/stylua.toml";
    };
  };
}
