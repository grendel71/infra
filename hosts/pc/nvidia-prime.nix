{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware.nvidia = {
    prime.sync.enable = true;

    prime.nvidiaBusId = "PCI:22:00:0";
    prime.intelBusId = "PCI:0:2:0";
  };
}
