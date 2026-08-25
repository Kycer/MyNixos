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

    # Keep the standalone nvim repository editable. Home Manager links the
    # complete submodule worktree instead of copying it into the Nix store.
    xdg.configFile."nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${configRoot}/home/programs/nvim/config";
  };
}
