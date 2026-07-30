{
  description = "Multi-host NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      hosts = import ./hosts;
      mkHost = import ./lib/mk-host.nix { inherit inputs; };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostName: host:
        mkHost {
          inherit hostName;
          inherit (host) system;
          hostModule = host.module;
        }
      ) hosts;
    };
}
