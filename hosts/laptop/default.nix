{ config, ... }:{  
imports = [
  ./hardware-configuration.nix
  ../../modules/desktop/plasma.nix
  #../../modules/programs/
  #../modules/
  ];

  networking.hostName = "blau-laptop"; # Define your hostname.

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "blau" = import ./home.nix;
    };
  };
}