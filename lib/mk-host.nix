{ inputs }:

{
  hostName,
  system,
  hostModule,
}:

let
  stablePkgs = import inputs.nixpkgs-stable {
    inherit system;
  };
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs stablePkgs;
  };

  modules = [
    inputs.home-manager.nixosModules.home-manager
    ../modules/nixos
    hostModule

    {
      networking.hostName = hostName;
    }
  ];
}
