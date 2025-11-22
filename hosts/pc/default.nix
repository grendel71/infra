{ config, inputs, ... }:{  
imports = [
  ./fs.nix
  ./hardware-configuration.nix
  ./nvidia.nix
  ./nvidia-prime.nix
  ./smb.nix
  ../../modules/programs
  ../../modules/desktop/plasma.nix
  ../../modules/system
  ../../modules/qemu
  #../modules/
  ];

  networking.hostName = "blau-pc"; # Define your hostname.
}
