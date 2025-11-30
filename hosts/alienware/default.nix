{ config, pkgs, inputs, ... }:
{
  imports = [
      ./hardware-configuration.nix
      ../../modules/desktop/sway.nix
      ../../modules/programs
      ../../configuration.nix
      ./nvidia.nix

  ];
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "blau" = import ./home.nix;
    };
  };
  services.tailscale.enable = true;
  hardware.bluetooth.enable = true;

  services.blueman.enable = true;
}