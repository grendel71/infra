{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polymc.url = "github:PolyMC/PolyMC";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    dotfiles = {
      url = "github:grendel71/dotfiles";
      flake = false;
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code.url = "github:sadjow/claude-code-nix";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self
    , nixpkgs
    , sops-nix
    , determinate
    , claude-code
    , nixpkgs-unstable
    , ...
    }@inputs:
    {
      nixosConfigurations.blau-pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          #./configuration.nix
          ./hosts/pc
          inputs.home-manager.nixosModules.default
          sops-nix.nixosModules.sops
          { nixpkgs.config.allowUnfree = true; }
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
          { nixpkgs.config.allowUnfree = true; }
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
          { nixpkgs.config.allowUnfree = true; }
        ];
      };

      hydraJobs = {
        blauPc = self.nixosConfigurations.blau-pc.config.system.build.toplevel;
        blauLaptop = self.nixosConfigurations.blau-laptop.config.system.build.toplevel;
      };
    };

}