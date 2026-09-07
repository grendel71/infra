{ config, pkgs, ... }:

{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["blau"];

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
}
