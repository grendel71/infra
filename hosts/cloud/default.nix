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
    ./disk-config.nix
  ];

  networking.hostName = "blau-cloud"; # Define your hostname.
  services.openssh.enable = true;

  users.users.blau = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnx/ZGyG6ED/Pe1SUWEDeGhuAl5PV6thdet6Pu9p55z blau@blau-pc"
    ];
  };

  services.fwupd.enable = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "blau" = import ../../home.nix;
    };
  };
 

}
