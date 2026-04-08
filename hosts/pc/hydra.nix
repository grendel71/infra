{ config, pkgs, ... }:
{
  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };

  nix = {
    buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        system = "x86_64-linux";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
        ];
        maxJobs = 8;
      }
    ];

    settings = {
      allowed-uris = [
        "github:"
        "git+https://github.com/"
      ];
      trusted-users = [
        "hydra"
        "hydra-queue-runner"
      ];
    };
  };

}
