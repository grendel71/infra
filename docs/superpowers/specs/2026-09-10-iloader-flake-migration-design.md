# iloader Flake Migration Design

**Date:** 2026-09-10
**Topic:** Replace the unstable nixpkgs iloader package with the upstream iloader flake

## Summary

Change the iloader package origin from `nixpkgs-unstable` to the upstream flake at [github:nab138/iloader](https://github.com/nab138/iloader). The package remains installed through the existing desktop Home Manager module.

## Approach

Add the upstream repository as a flake input and consume its default package directly. This keeps build and dependency definitions owned by upstream, while the lock file provides a reproducible revision.

## Changes

### `flake.nix`

Add an `iloader` input pointing to `github:nab138/iloader`. No nixpkgs following relationship or overlay is needed.

### `flake.lock`

Update the lock file so the new input and its transitive dependencies are pinned.

### `modules/apps/desktop.nix`

Replace `unstable.iloader` with:

```nix
inputs.iloader.packages.${pkgs.stdenv.hostPlatform.system}.default
```

The existing `inputs` and `pkgs` module arguments are sufficient.

## Scope and Constraints

- Only the package origin changes.
- Do not add `usbmuxd`, services, permissions, or other runtime integration.
- Do not modify unrelated uncommitted user changes.
- Preserve the existing desktop package placement and host coverage.

## Verification

Evaluate the affected NixOS configuration and confirm that the resulting home package set contains iloader from the upstream input. Review the diff to ensure only the intended input, lock data, and package reference changed.
