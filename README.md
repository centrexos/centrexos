# CentrexOS

**Engineered for Flexibility and Performance**

CentrexOS is a modern Linux distribution built around a unified package management layer, a modular monorepo architecture, and a performance-first kernel configuration. It targets developers and power users who want a reproducible, clean system without sacrificing flexibility.

---

## Quick Links

| Resource | Location |
|---|---|
| Architecture overview | [docs/architecture.md](docs/architecture.md) |
| Getting started | [docs/getting-started.md](docs/getting-started.md) |
| Developer guide | [docs/developer-guide.md](docs/developer-guide.md) |
| Contributing | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Website | https://centrexos.org |
| Issue tracker | https://github.com/centrexos/centrexos/issues |

---

## What is CentrexOS?

CentrexOS bridges the gap between distribution freedom and enterprise reliability by providing:

- **cxpkg** — a single CLI that talks to APT, DNF, and Flatpak transparently
- **Centrex Core** — a Rust runtime that bootstraps the base system and patches ELF binaries for the distro store
- **Custom kernel** — mainline Linux with the BORE scheduler, BBRv3 TCP, and desktop-optimised defaults
- **First-class desktop support** — KDE Plasma and GNOME layers with curated defaults and a CentrexOS theme
- **TUI installer** — a terminal-based interactive installer written in Rust/ratatui
- **Reproducible ISO builds** — squashfs-based live system built with a single `make iso`

---

## Architecture

```
                    CentrexOS
                        │
          ┌─────────────┼─────────────┐
          │             │             │
    Desktop Layer   Centrex Core   Installer
    (KDE / GNOME)   (Rust runtime)  (Rust TUI)
          │             │
          └──────┬───── ┘
                 │
              cxpkg  ←── Dependency Resolver
          ┌────┬┴────┐
          │    │     │
         APT  DNF  Flatpak
```

The resolver sits between cxpkg and the backends. It performs topological dependency sorting, conflict detection, and backend-priority routing. All user interactions go through cxpkg — the native package managers (apt-get, dnf) are not exposed directly to end users.

---

## Repository Structure

```
centrexos/                   ← monorepo root
├── core/                    ← Centrex Core (Rust) — runtime + bootstrapper
├── cxpkg/                   ← Unified package manager (Rust)
├── installer/               ← TUI installer (Rust + ratatui)
├── kernel/                  ← Kernel config, patches, build scripts
├── desktop-kde/             ← KDE Plasma layer (themes, SDDM, KWin)
├── desktop-gnome/           ← GNOME layer (gsettings, extensions, defaults)
├── metadata/                ← Package name maps and aliases (JSON)
├── branding/                ← Logo (SVG), color palette, Plymouth, GRUB theme
├── tooling/                 ← Release scripts, CI helpers, package generator
├── build/                   ← ISO build pipeline
├── scripts/                 ← Bootstrap and setup scripts
├── docs/                    ← All documentation
├── configs/                 ← System-wide config overlays
├── overlays/                ← Repository and package overlays
└── releases/                ← Built ISO and release archives
```

Each top-level directory under `core/`, `cxpkg/`, `installer/`, `kernel/`, `desktop-kde/`, `desktop-gnome/`, `metadata/`, `branding/`, `tooling/`, and `docs/` is a **git submodule** with its own repository under the `centrexos` GitHub organisation.

---

## Core Components

| Component | Language | Description |
|---|---|---|
| **Centrex Core** | Rust | Base runtime: rootfs extraction, ELF RPATH patching, DNF metadata parsing |
| **cxpkg** | Rust | Unified CLI package manager — APT, DNF, and Flatpak backends |
| **Resolver Engine** | Rust (inside cxpkg) | Topological dependency sort, conflict detection, backend routing |
| **Installer** | Rust | Full TUI installation wizard with disk partitioning and deployment |
| **Kernel** | C + shell | mainline Linux with BORE + BBRv3 + desktop tuning |
| **Desktop (KDE)** | QML + config | Plasma theme, SDDM login, KWin rules, colour scheme |
| **Desktop (GNOME)** | gsettings + config | Shell overrides, extension list, default apps |
| **Metadata** | JSON | Cross-backend package name mapping and alias resolution |
| **Branding** | SVG + script | Logo, Plymouth splash, GRUB theme, colour palette |
| **Tooling** | Bash | Release automation, CI checks, package metadata generator |

---

## Technology Stack

| Area | Technology |
|---|---|
| Core language | Rust (2021 edition) |
| TUI framework | ratatui |
| CLI parsing | clap v4 |
| Build system | GNU Make |
| CI/CD | GitHub Actions |
| Desktop (default) | KDE Plasma |
| Init system | systemd |
| Package backends | APT / DNF / Flatpak |
| Installer | centrex-installer (custom Rust TUI) |
| Kernel scheduler | BORE (Burst-Oriented Response Enhancer) |
| TCP congestion | BBRv3 |
| Boot splash | Plymouth |
| Bootloader | GRUB2 (UEFI + BIOS) / systemd-boot |

---

## Building the System

### Prerequisites

```sh
# Debian / Ubuntu
sudo apt install git make curl jq cargo rustup \
    build-essential debootstrap xorriso squashfs-tools \
    grub-pc-bin grub-efi-amd64-bin mtools \
    gcc bison flex bc dwarves pahole xz-utils libssl-dev libelf-dev

# Fedora
sudo dnf install git make curl jq cargo rustup gcc bison flex bc \
    dwarves pahole xz openssl-devel elfutils-libelf-devel \
    xorriso squashfs-tools grub2-tools grub2-pc grub2-efi-x64
```

### Full system build (recommended)

```sh
# 1. Clone
git clone --recurse-submodules https://github.com/centrexos/centrexos.git
cd centrexos

# 2. Build everything — deps check + Rust + kernel + ISO
sudo make dist

# ISO is written to:
#   releases/centrexos-0.1.0-amd64.iso
```

### Build variants

```sh
# GNOME desktop instead of KDE (default)
sudo make dist DESKTOP=gnome

# Use 7.0 testing kernel
sudo make dist SERIES=7.0

# GNOME + 7.0 kernel + custom version tag
sudo make dist DESKTOP=gnome SERIES=7.0 VERSION=0.2.0
```

### Build stages individually

If you've already run `make dist` once, you can rebuild a single stage:

```sh
# Stage 1 — verify tools
make check-deps

# Stage 2 — update submodules
make sync

# Stage 3 — Rust components only
make build

# Stage 4 — kernel only (default series from versions.json)
make kernel
make kernel SERIES=7.0      # specific series

# Stage 5 — ISO only (uses pre-built kernel + Rust artifacts)
sudo make iso
sudo make iso SERIES=7.0 DESKTOP=gnome
```

### Test the ISO

```sh
# QEMU (no root needed for testing)
qemu-system-x86_64 \
    -m 4G \
    -cdrom releases/centrexos-0.1.0-amd64.iso \
    -boot d \
    -enable-kvm \
    -vga virtio
```

### Clean and rebuild

```sh
make clean          # remove all artifacts (Rust, kernel output, ISO work dir)
make clean-rust     # Rust target/ only
make clean-kernel   # kernel output/ only
make clean-iso      # /tmp/centrexos-build only
```

See [docs/getting-started.md](docs/getting-started.md) for the full developer setup guide.

---

## cxpkg Usage

```sh
# Install a package (resolves deps, picks best backend)
cxpkg install firefox

# Search across all enabled backends
cxpkg search neovim

# Show detailed package info
cxpkg info vscode

# Update all package indexes
cxpkg update

# Upgrade all installed packages
cxpkg upgrade --all

# List installed packages
cxpkg list

# Show what would be installed without doing it
cxpkg install gimp --dry-run
```

See [docs/cxpkg.md](docs/cxpkg.md) for the full reference.

---

## Development Status

CentrexOS is in **early development**. Core infrastructure is in place; the following areas are actively being built:

- [x] Repository and monorepo architecture
- [x] cxpkg prototype with APT, DNF, Flatpak backends
- [x] Dependency resolver with topological sort
- [x] TUI installer with disk partitioning, deployment, bootloader
- [x] Kernel configuration and BORE/BBRv3 patches
- [x] KDE Plasma and GNOME desktop layers
- [x] Package metadata cross-reference (APT ↔ DNF ↔ Flatpak)
- [x] Plymouth boot splash and GRUB theme
- [x] Branding assets and CI pipeline
- [ ] ISO build pipeline (integration testing)
- [ ] Package repository server
- [ ] Immutable upgrade support
- [ ] Software Centre GUI

---

## Build Philosophy

- **Simplicity** — one command to build, one command to install
- **Modularity** — every component is a replaceable submodule
- **Transparency** — all build steps are scripted and auditable
- **Performance** — kernel and userspace defaults tuned for desktop responsiveness
- **Automation** — CI validates every commit; releases are scripted end-to-end

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contribution guide including branch naming, commit style, and PR checklist.

---

## License

MIT — see [LICENSE](LICENSE).
