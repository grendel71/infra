{ config, lib, pkgs, inputs, ... }:

let
  # Apply the polymc overlay locally
  pkgsWithPolyMC = import inputs.nixpkgs {
    inherit (pkgs) system;
    overlays = [ inputs.polymc.overlay ];
  };
in {
  home.packages = [
    pkgsWithPolyMC.polymc
  ];

  # Optional custom options, configurations, etc.
  # Example: PolyMC doesn't really need much here unless you want to manage configs manually.
}
