{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polymc.url = "github:PolyMC/PolyMC";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.blau-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hosts/pc
        inputs.home-manager.nixosModules.default
      ];
    };
    nixosConfigurations.blau-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hosts/laptop
        inputs.home-manager.nixosModules.default
      ];
    };
  };
}
