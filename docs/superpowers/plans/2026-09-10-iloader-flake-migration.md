# iloader Flake Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the `nixpkgs-unstable` iloader package with the pinned package exported by `github:nab138/iloader`.

**Architecture:** Add the upstream repository as a flake input, then consume its default package directly from `modules/apps/desktop.nix`. Keep the existing Home Manager package location and make no runtime or system-service changes.

**Tech Stack:** Nix flakes, NixOS, Home Manager

---

### Task 1: Wire the upstream iloader flake into the desktop package set

**Files:**
- Modify: `flake.nix` — add the upstream iloader input.
- Modify: `flake.lock` — pin the new input and its transitive inputs.
- Modify: `modules/apps/desktop.nix` — replace `unstable.iloader` with the upstream default package.

- [ ] **Step 1: Add the upstream input**

In the `inputs` block of `flake.nix`, add:

```nix
    iloader.url = "github:nab138/iloader";
```

Do not add a nixpkgs `follows` assignment or an overlay; the package is consumed directly through `inputs`.

- [ ] **Step 2: Replace the unstable package reference**

In `modules/apps/desktop.nix`, replace:

```nix
    unstable.iloader
```

with:

```nix
    inputs.iloader.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Leave all other package entries unchanged.

- [ ] **Step 3: Update the lock file**

Run:

```bash
nix flake lock --update-input iloader
```

Expected result: `flake.lock` contains an `iloader` node pinned to a GitHub revision, plus any upstream transitive inputs required by that flake.

- [ ] **Step 4: Check the focused diff**

Run:

```bash
git diff --check
git diff -- flake.nix flake.lock modules/apps/desktop.nix
```

Expected result: the diff contains only the new input, lock data required for it, and the package reference replacement. Do not stage or alter the pre-existing changes in `configuration.nix`, `dotfiles/kanshi/config`, `dotfiles/scripts/stconnect.sh`, `dotfiles/yazi/plugins/whoosh.yazi`, or `home.nix`.

- [ ] **Step 5: Evaluate the configured package set**

Run:

```bash
nix eval .#nixosConfigurations.blau-pc.config.home-manager.users.blau.home.packages --apply 'packages: builtins.map (package: package.pname or package.name or "unknown") packages' 2>&1 | grep -i iloader
```

Expected result: output contains `iloader`, and evaluation exits successfully.

- [ ] **Step 6: Commit only the migration files**

Run:

```bash
git add flake.nix flake.lock modules/apps/desktop.nix
git diff --cached --check
git diff --cached --name-only
git commit -m "fix: use upstream iloader flake"
```

Expected staged file list:

```text
flake.lock
flake.nix
modules/apps/desktop.nix
```
