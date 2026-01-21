{ config, pkgs, inputs, ... }:{  
imports = [
#  ./fs.nix
  ./hardware-configuration.nix
  #./nvidia.nix
  #./nvidia-prime.nix
  #./smb.nix
  ../../modules/programs/r.nix
  #../../modules/desktop/plasma.nix
  #../../modules/desktop/sway.nix
  ../../modules/desktop/niri.nix
  ../../modules/system
  #../../modules/qemu
  #../modules/
  ../../configuration.nix
  ./powermgmt.nix
  ];

  networking.hostName = "blau-laptop"; # Define your hostname.

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "blau" = import ./home.nix;
    };
  };
  services.openssh.enable = true;
}
