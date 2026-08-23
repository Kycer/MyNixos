{ osConfig, ... }:

let
  shell = osConfig.my.user.shell;

  shellAliases = {
    c = "clear";
    j = "just --global-justfile";
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
    vimdiff = "nvim -d";
  };
in
{
  programs = {
    fish.shellAliases = shellAliases;
    zsh.shellAliases = shellAliases;

    fzf = {
      enable = true;
      enableFishIntegration = shell == "fish";
      enableZshIntegration = shell == "zsh";
    };

    zoxide = {
      enable = true;
      enableFishIntegration = shell == "fish";
      enableZshIntegration = shell == "zsh";
    };
  };
}
