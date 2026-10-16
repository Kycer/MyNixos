{
  config,
  lib,
  ...
}:

let
  adapterFiles = lib.filterAttrs (
    name: type: name != "default.nix" && type == "regular" && lib.hasSuffix ".nix" name
  ) (builtins.readDir ./.);
  desktop = config.my.desktop;
  session = desktop.session;
  noctalia = session.enable && desktop.shellStyle == "noctalia";
  remote = config.my.remoteDesktop.wayvnc;
in
{
  # A new desktop adapter is discovered from its filename. No central import
  # list or desktop enum needs to be updated.
  imports = map (name: ./. + "/${name}") (builtins.attrNames adapterFiles);

  assertions = [
    {
      assertion = desktop.wm == "none" || session.enable;
      message = "The selected desktop adapter did not publish an active session.";
    }
    {
      assertion = !remote.enable || builtins.elem "wayvnc" session.capabilities;
      message = "The selected desktop adapter does not implement the WayVNC capability.";
    }
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = lib.mkIf session.enable "1";
  security.polkit.enable = lib.mkIf session.enable true;

  programs.noctalia = {
    enable = noctalia;
    # The Home Manager desktop adapter starts Noctalia with the selected
    # graphical session.
    systemd.enable = false;
    recommendedServices.enable = noctalia;
  };
}
