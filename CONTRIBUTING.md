# Contributing to CentrexOS

Thank you for your interest in contributing. This document covers everything you need to know to submit a change — from setting up your environment to getting a pull request merged.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Repository Structure](#repository-structure)
3. [Environment Setup](#environment-setup)
4. [Branch Naming](#branch-naming)
5. [Commit Style](#commit-style)
6. [Development Workflow](#development-workflow)
7. [Testing](#testing)
8. [Pull Request Checklist](#pull-request-checklist)
9. [Release Process](#release-process)
10. [Where to Ask for Help](#where-to-ask-for-help)

---

## Code of Conduct

Be respectful and constructive. Harassment, personal attacks, and dismissive language are not welcome. Any such behaviour may result in removal from the project.

---

## Repository Structure

CentrexOS is a **monorepo** with each top-level directory being a separate git submodule. Work on the correct submodule — do not make changes to a submodule from within the monorepo root.

```
centrexos/           ← monorepo (this repo)
├── core/            ← git submodule: centrexos/centrex-core
├── cxpkg/           ← git submodule: centrexos/cxpkg
├── installer/       ← git submodule: centrexos/centrex-installer
├── kernel/          ← git submodule: centrexos/centrex-kernel
├── desktop-kde/     ← git submodule: centrexos/centrex-desktop-kde
├── desktop-gnome/   ← git submodule: centrexos/centrex-desktop-gnome
├── metadata/        ← git submodule: centrexos/centrex-metadata
├── branding/        ← git submodule: centrexos/centrex-branding
├── tooling/         ← git submodule: centrexos/centrex-tooling
└── docs/            ← git submodule: centrexos/centrex-docs
```

When contributing to a submodule, open a PR against **that submodule's repository**, then update the monorepo's submodule pointer separately.

---

## Environment Setup

### Prerequisites

| Tool | Minimum version | Purpose |
|---|---|---|
| git | 2.30+ | Version control |
| Rust (via rustup) | stable | All Rust components |
| cargo | (comes with Rust) | Build and test |
| rustfmt | (comes with Rust) | Code formatting |
| clippy | (comes with Rust) | Linting |
| GNU Make | 4.0+ | Top-level build orchestration |
| shellcheck | any | Shell script linting (CI) |
| jq | any | Metadata validation scripts |
| parted | any | Installer disk tests |

### Install Rust

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rustfmt clippy
```

### Clone and bootstrap

```sh
git clone --recurse-submodules https://github.com/centrexos/centrexos.git
cd centrexos
make bootstrap
```

`make bootstrap` builds all Rust crates and creates the required directory skeleton. It installs binaries to `/usr/local/bin` if you run it as root.

---

## Branch Naming

All branches must follow this convention:

```
<type>/<short-description>
```

| Type | When to use |
|---|---|
| `feat/` | New feature or capability |
| `fix/` | Bug fix |
| `refactor/` | Code restructuring without behaviour change |
| `docs/` | Documentation only |
| `test/` | Tests only |
| `chore/` | Build system, tooling, CI, dependencies |
| `kernel/` | Kernel config or patch changes |
| `desktop/` | Desktop layer changes (KDE/GNOME) |

**Examples**

```
feat/flatpak-remote-management
fix/apt-backend-parse-multiline-desc
docs/cxpkg-reference
kernel/bore-scheduler-v6
chore/update-ratatui-0-30
```

Branch names must be lowercase, use hyphens (not underscores), and be concise (under 50 characters).

---

## Commit Style

CentrexOS uses **Conventional Commits**.

```
<type>(<scope>): <short summary>

[optional body — explain the WHY, not the WHAT]

[optional footer: Breaking-Change, Fixes #issue]
```

### Types

| Type | Use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Restructuring without behaviour change |
| `docs` | Documentation |
| `test` | Tests |
| `chore` | Build, tooling, CI, dependency updates |
| `perf` | Performance improvement |
| `style` | Formatting only (no logic change) |
| `revert` | Reverts a previous commit |

### Scope

Use the component name: `cxpkg`, `installer`, `core`, `kernel`, `desktop-kde`, `desktop-gnome`, `metadata`, `branding`, `tooling`, `docs`.

### Examples

```
feat(cxpkg): add flatpak remote add/remove commands

fix(installer): correctly detect nvme partition suffix (p1 not 1)

docs(contributing): add branch naming section

chore(deps): update ratatui to 0.30

kernel: add BORE scheduler v5.7.29 patch for 6.12
```

### Rules

- Summary line ≤ 72 characters
- Use present tense ("add feature", not "added feature")
- Do not end the summary with a period
- Reference issues in the footer: `Fixes #42` or `Closes #42`
- Breaking changes must include `BREAKING CHANGE:` in the footer

---

## Development Workflow

### 1. Create a branch

```sh
# Work inside the relevant submodule directory
cd cxpkg
git checkout -b feat/search-filter-by-category
```

### 2. Make changes

- Write code following the project conventions (see language-specific sections below)
- Keep changes focused — one logical change per PR
- Do not add unrelated cleanups to a feature PR

### 3. Run the pre-push check

```sh
# From the monorepo root
./tooling/scripts/ci-check.sh
```

This runs `cargo fmt --check`, `cargo clippy`, unit tests, JSON validation, and shellcheck. Fix all failures before opening a PR.

### 4. Open a PR

- Open the PR against the `main` branch of the relevant submodule repository
- Fill in the PR template (summary, test plan, screenshots if UI)
- Link any related issues

---

## Language-Specific Conventions

### Rust

```sh
# Format before every commit
cargo fmt --manifest-path <module>/Cargo.toml

# Must pass with zero warnings
cargo clippy --manifest-path <module>/Cargo.toml -- -D warnings

# Run tests
cargo test --manifest-path <module>/Cargo.toml
```

**Style rules**

- Use `thiserror` for library error types; `anyhow` in binaries
- Prefer `Result<T>` over `unwrap()` or `expect()` in production paths
- Do not use `#[allow(dead_code)]` to silence warnings in new code — remove the dead code or make it used
- Name modules after the concept they represent, not the file they live in
- Keep `pub` surface minimal — default to private, expose only what external code needs
- Error messages must be lowercase and not end with a period (Rust convention)

### Shell scripts

- `set -euo pipefail` at the top of every script
- Use `shellcheck`-clean scripts — no suppressions without an explicit comment explaining why
- Prefer `[[ ... ]]` over `[ ... ]`
- Quote all variable expansions: `"$var"`, not `$var`
- Use `local` for all variables inside functions

### JSON (metadata)

- Format with `jq . file.json` before committing
- Every new package entry must include `apt`, `dnf`, `flatpak`, `description`, and `category`
- Use `null` (not `""`) when a backend name is unavailable
- Aliases must be lowercase and use hyphens

### Configuration files (KDE, GNOME, kernel)

- Include a comment header identifying the file purpose and install path
- KDE `.config` and `kdeglobals` changes must be tested under a live KDE session
- Kernel `.config` changes must run through `make olddefconfig` before committing

---

## Testing

### Unit tests (Rust)

```sh
cargo test --manifest-path cxpkg/Cargo.toml
cargo test --manifest-path core/Cargo.toml
```

### Integration tests

Integration tests live in `tests/` inside each submodule. Run with:

```sh
cargo test --manifest-path cxpkg/Cargo.toml -- --ignored
```

Tests that require a live APT or DNF system are marked `#[ignore]` and run separately in CI on the appropriate runner.

### Installer smoke test

```sh
# Run the TUI in a terminal — navigate through all screens without installing
cargo run --manifest-path installer/Cargo.toml
```

### Metadata validation

```sh
find metadata -name "*.json" | xargs -I{} jq . {} > /dev/null
```

### Full CI check (run before every PR)

```sh
./tooling/scripts/ci-check.sh
```

---

## Pull Request Checklist

Before requesting a review, confirm:

- [ ] Branch name follows the naming convention
- [ ] Commits follow Conventional Commits style
- [ ] `cargo fmt -- --check` passes
- [ ] `cargo clippy -- -D warnings` passes (zero warnings)
- [ ] All existing tests pass
- [ ] New functionality has at least one unit test
- [ ] `./tooling/scripts/ci-check.sh` exits 0
- [ ] PR description explains **why** the change is needed, not just what it does
- [ ] Breaking changes are flagged with `BREAKING CHANGE:` in the commit footer and documented in the PR description
- [ ] Documentation updated if you changed a public API or behaviour

---

## Release Process

Releases are driven by the maintainers using `tooling/scripts/release.sh`.

```sh
./tooling/scripts/release.sh 0.2.0
```

This script:

1. Validates the version number (semver)
2. Runs the full test suite
3. Bumps all `Cargo.toml` versions
4. Builds release binaries
5. Packages them with a `SHA256SUMS` file
6. Creates an annotated git tag `v<version>`

After the release script, maintainers:

- Push the tag: `git push --tags`
- Publish the GitHub Release with the generated tarball
- Build and publish the ISO: `sudo make iso`

---

## Where to Ask for Help

| Channel | Use |
|---|---|
| [GitHub Issues](https://github.com/centrexos/centrexos/issues) | Bug reports, feature requests |
| [GitHub Discussions](https://github.com/centrexos/centrexos/discussions) | Questions, design discussions |
| [Website](https://centrexos.org) | General information |
