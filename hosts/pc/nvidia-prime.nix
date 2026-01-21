{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.nvidia-prime-sync.enable = mkEnableOption "Enable NVIDIA Prime synchronization with the specified bus IDs.";

  options.nvidia-prime-sync.amdgpuBusId = mkOption {
    type = types.str;
    default = "PCI:11:0:0";
    description = "PCI bus ID of the AMD integrated graphics card.";
  };

  options.nvidia-prime-sync.nvidiaBusId = mkOption {
    type = types.str;
    default = "PCI:1:0:0";
    description = "PCI bus ID of the NVIDIA dedicated graphics card.";
  };

  config = lib.mkIf config.nvidia-prime-sync.enable {
    hardware.nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = config.nvidia-prime-sync.amdgpuBusId;
      nvidiaBusId = config.nvidia-prime-sync.nvidiaBusId;
    };
  };
}
