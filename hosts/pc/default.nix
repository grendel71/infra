{ ... }:{  
imports = [
  ./fs.nix
  ./hardware-configuration.nix
  ./nvidia.nix
  ./nvidia-prime.nix
  ./smb.nix
  ../../modules/programs/steam.nix
  ../../system/wireguard.nix
  #../modules/
  ];
}