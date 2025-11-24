{ config, inputs, ... }:{  
imports = [
  ./hardware-configuration.nix
  #../../modules/desktop/plasma.nix
  ../../modules/desktop/sway.nix
  ../../modules/programs
  #../modules/
  ];

  networking.hostName = "blau-laptop"; # Define your hostname.
  services.tailscale.enable = true;

}
