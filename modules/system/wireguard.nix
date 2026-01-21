{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces.wg0.configFile = "/home/blau/dotfiles/wg/wg.conf";
}
