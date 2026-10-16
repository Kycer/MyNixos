{
  config,
  inputs,
  stablePkgs,
  ...
}:

let
  user = config.my.user.name;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs stablePkgs;
      # /etc/nixos is the stable seam used by out-of-store Home Manager
      # links; the installer points it at whichever checkout was selected.
      configRoot = "/etc/nixos";
    };

    users.${user} = {
      imports = [
        ../home
      ];

      home = {
        username = user;
        homeDirectory = "/home/${user}";
        stateVersion = "26.05";
      };
    };
  };
}
