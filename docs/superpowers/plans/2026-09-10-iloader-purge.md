# iloader Reference Purge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove every iloader reference from active configuration, lock data, and repository documentation.

**Architecture:** Remove the iloader input and desktop package reference, then regenerate the lockfile using the existing locked inputs so only iloader-specific dependency nodes disappear. Delete all iloader-only historical documents and verify a repository-wide case-insensitive search finds no remaining references.

**Tech Stack:** Nix flakes, NixOS, Home Manager, Markdown documentation

---

### Task 1: Remove iloader from active Nix configuration

**Files:**
- Modify: `flake.nix` — remove the `iloader` input line.
- Modify: `modules/apps/desktop.nix` — remove the iloader package entry.
- Modify: `flake.lock` — remove the iloader input graph without updating unrelated inputs.

- [ ] **Step 1: Remove the flake input**

Delete this line from `flake.nix`:

```nix
    iloader.url = "github:nab138/iloader/569b56d79804e3a4b5f4e0be862402c20b2a3fee";
```

- [ ] **Step 2: Remove the desktop package**

Delete this line from `modules/apps/desktop.nix`:

```nix
    inputs.iloader.packages.${pkgs.stdenv.hostPlatform.system}.default
```

- [ ] **Step 3: Regenerate the lockfile**

Run:

```bash
nix flake lock
```

Expected result: `flake.lock` no longer contains an `iloader` node or iloader-only transitive nodes, while unrelated locked inputs remain unchanged.

- [ ] **Step 4: Verify active configuration references are gone**

Run:

```bash
git diff --check
git grep -in iloader -- flake.nix flake.lock modules/apps/desktop.nix
```

Expected result: `git diff --check` succeeds and `git grep` returns no matches.

### Task 2: Delete iloader-specific documentation

**Files:**
- Delete: `docs/superpowers/specs/2026-06-23-iloader-integration-design.md`
- Delete: `docs/superpowers/plans/2026-06-23-iloader-integration.md`
- Delete: `docs/superpowers/specs/2026-09-10-iloader-flake-migration-design.md`
- Delete: `docs/superpowers/plans/2026-09-10-iloader-flake-migration.md`

- [ ] **Step 1: Delete the four historical documents**

Remove exactly the four paths listed above. Do not delete the purge design or purge implementation plan.

- [ ] **Step 2: Verify no repository references remain**

Run:

```bash
git grep -in iloader || true
```

Expected result: no output.

- [ ] **Step 3: Evaluate the affected NixOS configuration**

Run:

```bash
nix eval .#nixosConfigurations.blau-pc.config.home-manager.users.blau.home.packages --apply 'packages: builtins.map (package: package.pname or package.name or "unknown") packages' >/dev/null
```

Expected result: evaluation exits successfully.

- [ ] **Step 4: Review and commit only purge changes**

Run:

```bash
git status --short
git diff --stat
git add flake.nix flake.lock modules/apps/desktop.nix
git add -u -- docs/superpowers/specs/2026-06-23-iloader-integration-design.md docs/superpowers/plans/2026-06-23-iloader-integration.md docs/superpowers/specs/2026-09-10-iloader-flake-migration-design.md docs/superpowers/plans/2026-09-10-iloader-flake-migration.md
git diff --cached --check
git diff --cached --name-only
git commit -m "chore: remove iloader references"
```

Expected staged file list:

```text
docs/superpowers/plans/2026-06-23-iloader-integration.md
docs/superpowers/plans/2026-09-10-iloader-flake-migration.md
docs/superpowers/specs/2026-06-23-iloader-integration-design.md
docs/superpowers/specs/2026-09-10-iloader-flake-migration-design.md
flake.lock
flake.nix
modules/apps/desktop.nix
```
