{ config, ... }:{  
imports = [
  ./hardware-configuration.nix
  ../../modules/desktop/plasma.nix
  ../../modules/programs/steam.nix
  #../modules/
  ];

networking.hostName = "blau-laptop"; # Define your hostname.

}