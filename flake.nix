{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polymc.url = "github:PolyMC/PolyMC";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mysecrets = {
      url = "git+ssh://git@github.com:grendel71/nix-secrets.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, sops-nix, mysecrets, ... }@inputs: {
    nixosConfigurations.blau-pc = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit mysecrets; };
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hosts/pc
        inputs.home-manager.nixosModules.default
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.blau-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hosts/laptop
        inputs.home-manager.nixosModules.default
        sops-nix.nixosModules.sops
      ];
    };
  };
}
