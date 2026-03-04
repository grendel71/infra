{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polymc.url = "github:PolyMC/PolyMC";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
        # to have it up-to-date or simply don't specify the nixpkgs input
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        };
    };
    dotfiles = {
      url = "github:grendel71/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs: {
    nixosConfigurations.blau-pc = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        #./configuration.nix
        ./hosts/pc
        inputs.home-manager.nixosModules.default
        sops-nix.nixosModules.sops
      ];
      specialArgs = {
        inherit inputs;
      };
    };
    nixosConfigurations.blau-laptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        #./configuration.nix
        ./hosts/laptop
        inputs.home-manager.nixosModules.default
        sops-nix.nixosModules.sops
      ];
      specialArgs = {
	inherit inputs;
      };
    };
    nixosConfigurations.blau-alienware = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        #./configuration.nix
        ./hosts/alienware
        inputs.home-manager.nixosModules.default
        sops-nix.nixosModules.sops
      ];
    };
  };


}
