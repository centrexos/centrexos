# Graph Report - .  (2026-06-02)

## Corpus Check
- Corpus is ~22,882 words - fits in a single context window. You may not need a graph.

## Summary
- 323 nodes · 494 edges · 24 communities detected
- Extraction: 87% EXTRACTED · 13% INFERRED · 0% AMBIGUOUS · INFERRED: 66 edges (avg confidence: 0.79)
- Token cost: 18,500 input · 4,800 output

## Community Hubs (Navigation)
- [[_COMMUNITY_User Configuration|User Configuration]]
- [[_COMMUNITY_Desktop Branding & Identity|Desktop Branding & Identity]]
- [[_COMMUNITY_Network Configuration|Network Configuration]]
- [[_COMMUNITY_Project Overview & Core|Project Overview & Core]]
- [[_COMMUNITY_Package Metadata & Types|Package Metadata & Types]]
- [[_COMMUNITY_Package Backend Interface|Package Backend Interface]]
- [[_COMMUNITY_DNF Package Backend|DNF Package Backend]]
- [[_COMMUNITY_APT Package Backend|APT Package Backend]]
- [[_COMMUNITY_Disk Partition & Filesystem|Disk Partition & Filesystem]]
- [[_COMMUNITY_System Deployment|System Deployment]]
- [[_COMMUNITY_Chroot Install Environment|Chroot Install Environment]]
- [[_COMMUNITY_Installer UI (TUI)|Installer UI (TUI)]]
- [[_COMMUNITY_Flatpak Backend|Flatpak Backend]]
- [[_COMMUNITY_Disk Discovery|Disk Discovery]]
- [[_COMMUNITY_Bootloader Install|Bootloader Install]]
- [[_COMMUNITY_Core Bootstrapper|Core Bootstrapper]]
- [[_COMMUNITY_Locale & Timezone Config|Locale & Timezone Config]]
- [[_COMMUNITY_Kernel Patches & Series|Kernel Patches & Series]]
- [[_COMMUNITY_Package Format Translator|Package Format Translator]]
- [[_COMMUNITY_Dependency Resolver|Dependency Resolver]]
- [[_COMMUNITY_Filesystem Table Generator|Filesystem Table Generator]]
- [[_COMMUNITY_cxpkg CLI|cxpkg CLI]]
- [[_COMMUNITY_Installer Config Model|Installer Config Model]]
- [[_COMMUNITY_cxpkg Error Types|cxpkg Error Types]]

## God Nodes (most connected - your core abstractions)
1. `AptBackend` - 13 edges
2. `DnfBackend` - 13 edges
3. `run()` - 12 edges
4. `FlatpakBackend` - 12 edges
5. `Chroot` - 12 edges
6. `Deployer` - 11 edges
7. `CentrexOS Monorepo` - 11 edges
8. `App` - 10 edges
9. `centrex-installer` - 10 edges
10. `Config` - 9 edges

## Surprising Connections (you probably didn't know these)
- `centrex-installer` --semantically_similar_to--> `Centrex Core`  [INFERRED] [semantically similar]
  installer/README.md → core/README.md
- `KDE Plasma Desktop Layer` --semantically_similar_to--> `GNOME Desktop Layer`  [INFERRED] [semantically similar]
  desktop-kde/README.md → desktop-gnome/README.md
- `gsettings Override` --semantically_similar_to--> `CentrexDark Color Scheme`  [INFERRED] [semantically similar]
  desktop-gnome/README.md → desktop-kde/README.md
- `centrex-sddm Login Screen` --displays--> `CentrexOS Primary Logo (SVG)`  [EXTRACTED]
  desktop-kde/README.md → branding/logo/centrexos.svg
- `CentrexOS Monorepo` --contains_submodule--> `Centrex Core`  [EXTRACTED]
  README.md → core/README.md

## Hyperedges (group relationships)
- **cxpkg Package Resolution Flow** — cxpkg_readme_resolver_engine, cxpkg_readme_backend_registry, metadata_readme_metadata, metadata_readme_aliases_json, cxpkg_readme_resolution_plan [EXTRACTED 0.95]
- **ISO Build Pipeline** — readme_make_build_system, readme_iso_build, docs_architecture_squashfs, kernel_readme_centrex_kernel, branding_readme_grub_theme, branding_readme_plymouth [INFERRED 0.82]
- **CentrexOS Visual Identity System** — branding_readme_color_palette, logo_centrexos_svg, branding_readme_grub_theme, branding_readme_plymouth, desktop_kde_readme_centrex_dark [INFERRED 0.88]

## Communities

### Community 0 - "User Configuration"
Cohesion: 0.11
Nodes (22): UserConfig, format_partition(), run(), BackendConfig, CacheConfig, Config, config_path(), ResolverConfig (+14 more)

### Community 1 - "Desktop Branding & Identity"
Cohesion: 0.08
Nodes (33): GRUB Boot Menu Component, centrex-branding, CentrexOS Color Palette, centrex-theme GRUB2 Theme, centrex-splash Plymouth Theme, Tokyo Night Color Scheme, GNOME Desktop Layer, gsettings Override (+25 more)

### Community 2 - "Network Configuration"
Cohesion: 0.11
Nodes (10): NetworkConfig, NetworkMethod, Resolver<'a>, render(), render(), render_done(), render(), section() (+2 more)

### Community 3 - "Project Overview & Core"
Cohesion: 0.11
Nodes (23): Conventional Commits Style, CoreBootstrapper, Centrex Core, PackagingEngine (Translator), AptBackend, BackendRegistry, cxpkg, DnfBackend (+15 more)

### Community 4 - "Package Metadata & Types"
Cohesion: 0.1
Nodes (8): BackendKind, Dependency, Package, PackageQuery, PackageState, semver_compare(), VersionOp, VersionReq

### Community 5 - "Package Backend Interface"
Cohesion: 0.18
Nodes (4): Backend, BackendRegistry, command_exists(), run_command()

### Community 6 - "DNF Package Backend"
Cohesion: 0.26
Nodes (2): DnfBackend, parse_dnf_size()

### Community 7 - "APT Package Backend"
Cohesion: 0.29
Nodes (1): AptBackend

### Community 8 - "Disk Partition & Filesystem"
Cohesion: 0.21
Nodes (6): FilesystemKind, PartitionEntry, PartitionKind, PartitionPlan, PartitionTable, recommended_swap_mib()

### Community 9 - "System Deployment"
Cohesion: 0.31
Nodes (2): Deployer, DeploySource

### Community 10 - "Chroot Install Environment"
Cohesion: 0.29
Nodes (1): Chroot

### Community 11 - "Installer UI (TUI)"
Cohesion: 0.26
Nodes (4): App, AppEvent, render_error(), Screen

### Community 12 - "Flatpak Backend"
Cohesion: 0.27
Nodes (1): FlatpakBackend

### Community 13 - "Disk Discovery"
Cohesion: 0.29
Nodes (6): Disk, DiskPartition, DiskProber, probe_partitions(), read_sysfs_string(), read_sysfs_u64()

### Community 14 - "Bootloader Install"
Cohesion: 0.42
Nodes (9): bind_mount(), BootloaderKind, find_latest_kernel(), install_bootloader(), install_grub_bios(), install_grub_efi(), install_systemd_boot(), umount_bind_mounts() (+1 more)

### Community 15 - "Core Bootstrapper"
Cohesion: 0.39
Nodes (1): CoreBootstrapper

### Community 16 - "Locale & Timezone Config"
Cohesion: 0.32
Nodes (5): available_locales(), available_timezones(), collect_timezones(), LocaleConfig, render()

### Community 17 - "Kernel Patches & Series"
Cohesion: 0.36
Nodes (8): AppArmor (MAC), BBRv3 TCP Congestion, BORE Scheduler, centrex-kernel, EEVDF Scheduler, Kernel Series 6.12 (LTS), Kernel Series 6.18 (Stable), Kernel Series 7.0 (Testing)

### Community 18 - "Package Format Translator"
Cohesion: 0.47
Nodes (2): PackagingEngine, RepoPackage

### Community 19 - "Dependency Resolver"
Cohesion: 0.33
Nodes (2): ResolutionPlan, Resolver

### Community 20 - "Filesystem Table Generator"
Cohesion: 0.53
Nodes (4): fs_str(), fstab_fields(), generate_fstab(), get_uuid()

### Community 21 - "cxpkg CLI"
Cohesion: 0.5
Nodes (3): Cli, Commands, ConfigAction

### Community 22 - "Installer Config Model"
Cohesion: 0.5
Nodes (2): DesktopChoice, InstallConfig

### Community 23 - "cxpkg Error Types"
Cohesion: 1.0
Nodes (1): CxpkgError

## Knowledge Gaps
- **41 isolated node(s):** `RepoPackage`, `CxpkgError`, `BackendConfig`, `ResolverConfig`, `CacheConfig` (+36 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `DNF Package Backend`** (14 nodes): `DnfBackend`, `.info()`, `.install()`, `.list_installed()`, `.list_upgradable()`, `.name()`, `.new()`, `.parse_info_output()`, `.remove()`, `.search()`, `.update_index()`, `.upgrade_all()`, `parse_dnf_size()`, `dnf.rs`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `APT Package Backend`** (13 nodes): `AptBackend`, `.info()`, `.install()`, `.list_installed()`, `.list_upgradable()`, `.name()`, `.new()`, `.parse_dpkg_output()`, `.remove()`, `.search()`, `.update_index()`, `.upgrade_all()`, `apt.rs`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `System Deployment`** (13 nodes): `Deployer`, `.cleanup()`, `.deploy()`, `.deploy_network()`, `.deploy_rootfs()`, `.deploy_squashfs()`, `.install_centrex_binaries()`, `.new()`, `.post_deploy()`, `.setup_machine_id()`, `.write_os_release()`, `DeploySource`, `deploy.rs`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Chroot Install Environment`** (13 nodes): `Chroot`, `.create_user()`, `.enable_service()`, `.mount_pseudo()`, `.new()`, `.run()`, `.run_output()`, `.set_hostname()`, `.set_locale()`, `.set_timezone()`, `.umount_pseudo()`, `.write_file()`, `chroot.rs`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Flatpak Backend`** (12 nodes): `FlatpakBackend`, `.info()`, `.install()`, `.list_installed()`, `.list_upgradable()`, `.name()`, `.new()`, `.remove()`, `.search()`, `.update_index()`, `.upgrade_all()`, `flatpak.rs`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Core Bootstrapper`** (8 nodes): `bootstrapper.rs`, `CoreBootstrapper`, `.create_centrex_dirs()`, `.disable_foreign_package_managers()`, `.extract_local_rootfs()`, `.finalize_core_layout()`, `.new()`, `.write_os_release()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Package Format Translator`** (6 nodes): `translator.rs`, `PackagingEngine`, `.new()`, `.parse_dnf_metadata()`, `.patch_rpath()`, `RepoPackage`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Dependency Resolver`** (6 nodes): `mod.rs`, `ResolutionPlan`, `.is_empty()`, `.package_count()`, `.total_download_size()`, `Resolver`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Installer Config Model`** (4 nodes): `DesktopChoice`, `.fmt()`, `InstallConfig`, `mod.rs`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `cxpkg Error Types`** (2 nodes): `error.rs`, `CxpkgError`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DnfBackend` connect `DNF Package Backend` to `Package Backend Interface`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Why does `AptBackend` connect `APT Package Backend` to `Package Backend Interface`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._
- **What connects `RepoPackage`, `CxpkgError`, `BackendConfig` to the rest of the system?**
  _41 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `User Configuration` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Desktop Branding & Identity` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Network Configuration` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Project Overview & Core` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._