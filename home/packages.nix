{
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  home.packages =
    osConfig.my.packages.home
    ++ (with pkgs; [
      fzf
      htop
      just
      p7zip
      pciutils
      prettierd
      ripgrep
      shfmt
      stylua
      taplo
      unzip
      usbutils
      xz
      zip
    ])
    ++ lib.optionals osConfig.my.programs.networkTools.enable (
      with pkgs;
      [
        bind.dnsutils
        curl
        iperf3
        ldns
        nmap
        socat
        traceroute
        wget
        whois
      ]
    );
}
