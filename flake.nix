{
  description = "System config";

  nixConfig = {
    extra-substituters = [ "https://codex-cli.cachix.org" ];
    extra-trusted-public-keys = [
      "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
    ];
  };

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

    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
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
    {
      self,
      nixpkgs,
      sops-nix,
      determinate,
      claude-code,
      nixpkgs-unstable,
      codex-cli-nix,
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
      hydraJobs = {
        blauPc = self.nixosConfigurations.blau-pc.config.system.build.toplevel;
        blauLaptop = self.nixosConfigurations.blau-laptop.config.system.build.toplevel;
      };
    };

}
