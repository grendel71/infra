nix run github:nix-community/nixos-anywhere -- --flake .#$1 --generate-hardware-config nixos-generate-config $2/hardware-configuration.nix $3
