{ ... }:
{
  imports = [
    ./programs
    ./niri.nix
    ./sops.nix
    ./networking.nix
    ./compiler.nix
    ./wireguard.nix
  ];
}
