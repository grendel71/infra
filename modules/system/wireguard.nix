{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces.wg0.configFile = "/etc/nixos/files/wireguard/wg0-client-blaupc.conf";
}
