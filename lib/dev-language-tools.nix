{
  # Package strings are emitted as attributes from the generated `pkgs` set.
  # Shell variables use `value` for strings or `expression` for a Nix expression.
  go = {
    packages = [
      "delve"
      "go"
      "golangci-lint"
      "gopls"
    ];

    shellVariables = [
      {
        name = "GOTOOLCHAIN";
        value = "local";
      }
    ];
  };

  node = {
    packages = [
      "nodejs_26"
      "pnpm"
      "prettierd"
    ];
  };

  python = {
    packages = [
      "python3"
      "ruff"
      "uv"
    ];

    shellVariables = [
      {
        name = "UV_PYTHON_DOWNLOADS";
        value = "never";
      }
    ];
  };

  rust = {
    packages = [
      "cargo"
      "clippy"
      "rust-analyzer"
      "rustc"
      "rustfmt"
    ];

    shellVariables = [
      {
        name = "RUST_SRC_PATH";
        expression = "pkgs.rustPlatform.rustLibSrc";
      }
    ];
  };
}
