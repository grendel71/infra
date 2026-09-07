{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces.wg0.configFile = "/home/blau/Stevens/SSMIF/wg/client-wg0.yaml";
}
