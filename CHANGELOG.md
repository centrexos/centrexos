# CentrexOS Changelog

All notable changes to CentrexOS are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions correspond to `make dist VERSION=X.Y.Z` and the git tag `vX.Y.Z`.

---

## [Unreleased]

### Added
- Kernel series 7.1 (testing): io_uring v6, BPF arena, Intel FRED, TDX guest, WiFi 7
- `rust-toolchain.toml` at repo root pins stable toolchain — fixes `rustup` shim errors
  in environments without a configured default

### Fixed
- `build-iso.sh` Stage 3: install `initramfs-tools` inside the chroot before calling
  `update-initramfs` — custom kernel builds no longer silently skip initrd generation
- `build-iso.sh` Stage 9: removed invalid `-r` flag passed to `xorriso` via
  `grub-mkrescue` (Rock Ridge is handled automatically; the flag is a `mkisofs`-ism)
- `kernel/output/*/build.json`: `kver` field captured `make[2]: Entering directory`
  noise because `make -s kernelrelease` emitted directory-enter lines on some hosts;
  fixed by adding `--no-print-directory` and stripping `^make\[` lines

### Changed
- `kernel/scripts/build-kernel.sh`: `kver` capture is now
  `make -s --no-print-directory kernelrelease 2>/dev/null | grep -v '^make\[' | tr -d '[:space:]'`

---

## [0.1.0] — 2026-06-22

Initial release of CentrexOS.

### Components

| Component | Version | Notes |
|---|---|---|
| centrex-core | 0.1.0 | Rust runtime: bootstrapper, translator, package engine |
| cxpkg | 0.1.0 | Unified package manager (APT + DNF + Flatpak) |
| centrex-installer | 0.1.0 | Rust/ratatui TUI installer |
| Kernel default | 6.12.32 | LTS — BORE scheduler, BBRv3, AppArmor |

### Added

#### centrex-core
- System bootstrapper: directory scaffold, os-release, machine-id, locale
- ELF translator: RPATHs patching for the centrex store (`/opt/centrex_store`)
- DNF/RPM metadata parser for cross-distro package translation
- Removes native package manager binaries post-bootstrap so cxpkg is the sole interface

#### cxpkg
- Unified CLI: `install`, `remove`, `search`, `info`, `update`, `upgrade`, `list`, `config`
- Backend registry with priority ordering (APT → Flatpak → DNF by default)
- Resolver engine: BFS dependency graph, Kahn topological sort, conflict detection
- Per-backend dispatch: stateless wrappers around `apt-get`, `dnf`, `flatpak` CLIs
- Config at `/etc/cxpkg/config.toml` (overridable via `CXPKG_CONFIG` env var)
- Progress spinners via `indicatif`; confirmation prompts (bypass with `-y`)

#### centrex-installer
- Terminal UI built with `ratatui` + `crossterm`
- Disk selection and partitioning screen
- Desktop selection (KDE / GNOME / minimal)
- Locale, timezone, and user configuration
- Live system installation via `chroot` + `centrex-core` bootstrap

#### Kernel
- Series 6.12 (LTS, default): BORE scheduler v5.7.29, BBRv3 TCP, AppArmor,
  Zswap/zstd, EROFS, USB4, AMD SEV, io_uring
- Series 6.18 (stable): BORE v5.7.29, same patch set as 6.12
- Series 7.0 (testing): EEVDF + BORE v6.0, Rust modules, Shadow Stack (Intel CET),
  bcachefs, Intel Xe DRM, AMD SEV-SNP, PSI cgroup pressure

#### Build system
- Top-level `Makefile` with `dist`, `build`, `kernel`, `iso` pipeline
- `build/build-iso.sh`: debootstrap → kernel → binaries → desktop → squashfs → ISO
- `kernel/Makefile` and `scripts/`: download, patch, configure, build, package, install
- `scripts/bootstrap.sh`: installs host build dependencies
- `scripts/check-deps.sh`: preflight dependency check for ISO and kernel builds

#### Branding
- CentrexOS SVG logo (light + white variants)
- Plymouth splash theme (`centrex-splash`)
- GRUB bootloader theme (`centrex-theme`)
- KDE and GNOME default configurations and colour schemes

[Unreleased]: https://github.com/centrexos/centrexos/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/centrexos/centrexos/releases/tag/v0.1.0
