{ config, stablePkgs, ... }:

let
  user = config.my.user.name;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit stablePkgs;
    };

    users.${user} = {
      imports = [
        ../../home
      ];

      home = {
        username = user;
        homeDirectory = "/home/${user}";
        stateVersion = "26.05";
      };
    };
  };
}
