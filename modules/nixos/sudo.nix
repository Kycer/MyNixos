{ config, lib, pkgs, ... }:

{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;

    extraRules = lib.optionals config.my.sudo.passwordlessPowerCommands [
      {
        groups = [ "wheel" ];
        commands = map
          (command: {
            inherit command;
            options = [ "NOPASSWD" ];
          })
          [
            "${pkgs.systemd}/bin/systemctl suspend"
            "${pkgs.systemd}/bin/reboot"
            "${pkgs.systemd}/bin/poweroff"
          ];
      }
    ];
  };
}
