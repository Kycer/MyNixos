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
      htop
      just
      p7zip
      ripgrep
      unzip
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
