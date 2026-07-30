{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../configuration.nix
    ./autofs.nix
    ./powermgmt.nix
    ../pc/nvidia.nix
    ../pc/nvidia-prime.nix
  ];

  networking.hostName = "blau-laptop"; # Define your hostname.

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "blau" = import ../../home.nix;
    };
  };
  services.openssh.enable = true;

  users.users.blau = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnx/ZGyG6ED/Pe1SUWEDeGhuAl5PV6thdet6Pu9p55z blau@blau-pc"
    ];
  };

  services.hardware.bolt.enable = true;
  services.fwupd.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 16 GiB
    }
  ];
}
