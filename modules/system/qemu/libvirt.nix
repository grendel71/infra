{ config, pkgs, ... }:

{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["blau"];

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemuRunAsRoot = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.verbatimConfig = ''
    user = "blau"
    group = "users"
    cgroup_device_acl = [
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm",
    "/dev/userfaultfd",
    "/dev/input/by-id/usb-Logitech_G502_HERO_Gaming_Mouse_0480344F3937-event-mouse",
    "/dev/input/by-id/usb-Keychron_Keychron_C1-event-kbd"
    ]
    
    
    '';
  };
  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "with-vfio" ];
    vfio.enable = true;
  };
  users.users.blau = {
    extraGroups = [ "input" ];
  };

  

}