{ config, pkgs, inputs, ... }:{  
imports = [
  ./fs.nix
  ./hardware-configuration.nix
  ./nvidia.nix
  ./nvidia-prime.nix
  ./smb.nix
  #../../modules/programs/r.nix
  ../../modules/programs
  #../../modules/desktop/plasma.nix
  #../../modules/desktop/sway.nix
  ../../modules/desktop/niri.nix
  ../../modules/system
  ../../modules/qemu
  #../modules/
  ../../configuration.nix
  ];

  networking.hostName = "blau-pc"; # Define your hostname.

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "blau" = import ./home.nix;
    };
  };
  services.ollama = {
  enable = false;
  # Optional: preload models, see https://ollama.com/library
  #loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
  acceleration = "cuda";
};
  services.openssh.enable = true;
  users.users.blau = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+gzK8xwCY7/YsF1TeJjMrjwCjNjzRUTHB5ILNIqCL1 blau@blau-laptop"
    ];
  };
}
