{ ... }:{  
imports = [
  #./wireguard.nix
  #./sops.nix
  ./programs
  ./niri.nix
  ./sops.nix
  ./networking.nix
];

}