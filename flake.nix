{
  description = "System config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iloader.url = "github:nab138/iloader";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

  };
  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      determinate,
      claude-code,
      nixpkgs-unstable,
      zen-browser,
      disko,
      nixos-facter-modules,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      sharedModules = [
        inputs.home-manager.nixosModules.default
        sops-nix.nixosModules.sops

        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            (final: _prev: {
              unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
            })
            inputs.polymc.overlay
            claude-code.overlays.default

          ];
        }
      ];
    in
    {
      nixosConfigurations.blau-pc = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = sharedModules ++ [
          ./hosts/pc
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      nixosConfigurations.blau-laptop = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = sharedModules ++ [
          ./hosts/laptop
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      nixosConfigurations.blau-tlaptop = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = sharedModules ++ [
          disko.nixosModules.disko
          ./hosts/tlaptop
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };

}
