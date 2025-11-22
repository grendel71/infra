{ config, inputs, ... }:{  
imports = [
  ./fs.nix
  ./hardware-configuration.nix
  ./nvidia.nix
  ./nvidia-prime.nix
  ./smb.nix
  ../../modules/programs/
  ../../system/
  #../modules/
  ];

  networking.hostName = "blau-pc"; # Define your hostname.
}
