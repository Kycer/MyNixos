{
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.my.user.shell == "zsh") {
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };

      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      history = {
        append = true;
        extended = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        save = 100000;
        size = 100000;
        share = true;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
        ];
      };

      initContent = ''
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      '';
    };
  };
}
