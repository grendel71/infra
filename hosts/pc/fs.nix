{ config, pkgs, ... }:
{
  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/5b2a7471-92eb-4135-aa4e-22cb8f1dc713";
      fsType = "ext4";
    };
  fileSystems."/home/blau/games" =
    { device = "/dev/disk/by-uuid/6f164541-101a-40f3-b8d6-1d11e77fdfd6";
      fsType = "ext4";
    };
}