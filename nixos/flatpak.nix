{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.flatpak;
  flatpak = lib.getExe config.services.flatpak.package;
  packageRemoteNames = builtins.attrNames cfg.packages;
  unknownRemotes = lib.filter (name: !(builtins.hasAttr name cfg.remotes)) packageRemoteNames;

  remoteCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: remote:
      let
        nameArg = lib.escapeShellArg name;
        locationArg = lib.escapeShellArg remote.location;
      in
      ''
        if ! ${flatpak} remotes --system --columns=name \
          | ${pkgs.gnugrep}/bin/grep --fixed-strings --line-regexp --quiet ${nameArg}; then
          ${flatpak} remote-add --system --if-not-exists ${nameArg} ${locationArg}
        fi
        ${lib.optionalString (remote.url != null) ''
          ${flatpak} remote-modify --system --url=${lib.escapeShellArg remote.url} ${nameArg}
        ''}
      ''
    ) cfg.remotes
  );

  packageCommands = lib.concatStringsSep "\n" (
    lib.flatten (
      lib.mapAttrsToList (
        remote: appIds:
        map (
          appId:
          let
            remoteArg = lib.escapeShellArg remote;
            appIdArg = lib.escapeShellArg appId;
          in
          ''
            origin="$(${flatpak} info --system --show-origin ${appIdArg} 2>/dev/null || true)"
            if [ -z "$origin" ]; then
              ${flatpak} install --system --noninteractive --assumeyes ${remoteArg} ${appIdArg}
            elif [ "$origin" != ${remoteArg} ]; then
              echo "Flatpak ${appId} is installed from '$origin'; expected ${remote}." >&2
              exit 1
            fi
          ''
        ) appIds
      ) cfg.packages
    )
  );
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = unknownRemotes == [ ];
        message = "my.flatpak.packages references undeclared remotes: ${lib.concatStringsSep ", " unknownRemotes}";
      }
    ];

    services.flatpak.enable = true;
    xdg.portal.enable = true;

    systemd.services.flatpak-managed-install = {
      description = "Install host-declared system Flatpak applications";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      script = ''
        set -euo pipefail

        ${remoteCommands}
        ${packageCommands}
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "infinity";
      };
    };
  };
}
