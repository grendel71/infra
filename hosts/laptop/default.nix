{ config, pkgs, inputs, ... }:{  
imports = [
  ./hardware-configuration.nix
  #../../modules/desktop/plasma.nix
  ../../modules/desktop/sway.nix
  ../../modules/programs
  #../modules/
  ../../configuration.nix
  ];

  networking.hostName = "blau-laptop"; # Define your hostname.
  services.tailscale.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "blau" = import ./home.nix;
    };
  };
}
