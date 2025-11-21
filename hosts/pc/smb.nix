{ config, lib, pkgs, ... }:

{
  services.samba = {
  enable = true;
  securityType = "user";
  openFirewall = true;
  settings = {
    "private" = {
      "path" = "/home/blau/sharedfs";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "blau";
      "force group" = "users";
    };
  };
};

services.samba-wsdd = {
  enable = true;
  openFirewall = true;
};

networking.firewall.enable = true;
networking.firewall.allowPing = true;
}