# iloader Reference Purge Design

**Date:** 2026-09-10
**Topic:** Remove all iloader references from the infra repository

## Summary

Remove iloader from both the active Nix configuration and repository documentation. The purge covers the flake input, locked dependency graph, desktop package list, and all iloader-specific historical design and implementation-plan documents.

## Changes

### Active configuration

- Remove the `iloader` input from `flake.nix`.
- Remove the upstream iloader package from `modules/apps/desktop.nix`.
- Regenerate `flake.lock` so the iloader node and iloader-only transitive nodes are removed without updating unrelated inputs.

### Documentation

Delete these iloader-specific documents:

- `docs/superpowers/specs/2026-06-23-iloader-integration-design.md`
- `docs/superpowers/plans/2026-06-23-iloader-integration.md`
- `docs/superpowers/specs/2026-09-10-iloader-flake-migration-design.md`
- `docs/superpowers/plans/2026-09-10-iloader-flake-migration.md`

## Scope and Constraints

- After the purge, repository search must find no `iloader` references.
- Preserve all unrelated user changes currently present in the worktree.
- Do not modify unrelated Nix inputs, packages, or services.
- Do not add replacement sideloading functionality.

## Verification

Run `git diff --check`, evaluate the affected NixOS configuration, and search the repository for `iloader` case-insensitively. Review the staged file list to ensure only the intended configuration, lock, and iloader-specific documentation changes are included.
