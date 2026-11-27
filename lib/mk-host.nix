{ inputs }:

{
  hostName,
  system,
  hostModule,
  nurPkgs,
}:

let
  stablePkgs = import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs nurPkgs stablePkgs;
  };

  modules = [
    inputs.home-manager.nixosModules.home-manager
    ../nixos
    hostModule

    {
      networking.hostName = hostName;
    }
  ];
}
