# Graph Report - centrexos  (2026-06-24)

## Corpus Check
- 92 files · ~30,576 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 836 nodes · 1612 edges · 56 communities (55 shown, 1 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 68 edges (avg confidence: 0.79)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2a46d2a9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

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
- [[_COMMUNITY_KWin Rules Script|KWin Rules Script]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]

## God Nodes (most connected - your core abstractions)
1. `CxpkgError` - 39 edges
2. `App` - 31 edges
3. `BackendRegistry` - 24 edges
4. `centrex-installer` - 18 edges
5. `Config` - 17 edges
6. `CentrexOS` - 17 edges
7. `run()` - 16 edges
8. `centrex-kernel` - 16 edges
9. `FlatpakBackend` - 14 edges
10. `CentrexOS Developer Guide` - 14 edges

## Surprising Connections (you probably didn't know these)
- `centrex_core` --semantically_similar_to--> `centrex-installer`  [INFERRED] [semantically similar]
  core/README.md → installer/README.md
- `GNOME Desktop Layer` --semantically_similar_to--> `KDE Plasma Desktop Layer`  [INFERRED] [semantically similar]
  desktop-gnome/README.md → desktop-kde/README.md
- `gsettings Override` --semantically_similar_to--> `CentrexDark Color Scheme`  [INFERRED] [semantically similar]
  desktop-gnome/README.md → desktop-kde/README.md
- `centrex-metadata` --writes_to--> `gen-package.sh`  [EXTRACTED]
  metadata/README.md → tooling/README.md
- `PackagingEngine (Translator)` --provides_metadata_to--> `DnfBackend`  [INFERRED]
  core/README.md → cxpkg/README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **cxpkg Package Resolution Flow** — cxpkg_readme_resolver_engine, cxpkg_readme_backend_registry, metadata_readme_metadata, metadata_readme_aliases_json, cxpkg_readme_resolution_plan [EXTRACTED 0.95]
- **ISO Build Pipeline** — readme_make_build_system, readme_iso_build, docs_architecture_squashfs, kernel_readme_centrex_kernel, branding_readme_grub_theme, branding_readme_plymouth [INFERRED 0.82]
- **CentrexOS Visual Identity System** — branding_readme_color_palette, logo_centrexos_svg, branding_readme_grub_theme, branding_readme_plymouth, desktop_kde_readme_centrex_dark [INFERRED 0.88]

## Communities (56 total, 1 thin omitted)

### Community 0 - "User Configuration"
Cohesion: 0.16
Nodes (23): Cli, main(), ProgressBar, Self, BackendConfig, BackendsConfig, CacheConfig, Config (+15 more)

### Community 1 - "Desktop Branding & Identity"
Cohesion: 0.13
Nodes (22): GRUB Boot Menu Component, centrex-branding, CentrexOS Color Palette, Colour Palette, GRUB Theme, Installing the GRUB theme, Installing the Plymouth theme, Logo (+14 more)

### Community 2 - "Network Configuration"
Cohesion: 0.05
Nodes (39): [0.1.0] — 2026-06-22, Added, Added, Branding, Build system, centrex-core, centrex-installer, CentrexOS Changelog (+31 more)

### Community 3 - "Project Overview & Core"
Cohesion: 0.15
Nodes (14): GitHub Actions CI/CD, Semantic Versioning, GitHub Actions Build Workflow, Adding a New Script, centrex-tooling, ci-check.sh, CI Pipeline (`ci/build.yml`), gen-package.sh (+6 more)

### Community 4 - "Package Metadata & Types"
Cohesion: 0.06
Nodes (46): AsRef, available_locales(), available_timezones(), collect_timezones(), LocaleConfig, DesktopChoice, InstallConfig, NetworkConfig (+38 more)

### Community 5 - "Package Backend Interface"
Cohesion: 0.06
Nodes (19): Backend, AptBackend, DnfBackend, parse_dnf_size(), FlatpakBackend, Backend, BackendRegistry, command_exists() (+11 more)

### Community 6 - "DNF Package Backend"
Cohesion: 0.06
Nodes (33): additionalProperties, $ref, description, items, type, description, type, enum (+25 more)

### Community 7 - "APT Package Backend"
Cohesion: 0.06
Nodes (33): 1. Create a branch, 2. Make changes, 3. Run the pre-push check, 4. Open a PR, Branch Naming, Clone and bootstrap, Code of Conduct, Commit Style (+25 more)

### Community 8 - "Disk Partition & Filesystem"
Cohesion: 0.26
Nodes (7): FilesystemKind, PartitionEntry, PartitionKind, PartitionPlan, PartitionTable, recommended_swap_mib(), PathBuf

### Community 9 - "System Deployment"
Cohesion: 0.06
Nodes (20): Backend, run(), run(), run(), run(), AptBackend, DnfBackend, main() (+12 more)

### Community 10 - "Chroot Install Environment"
Cohesion: 0.06
Nodes (31): 1. Work inside the submodule, 2. Code, format, lint, 3. Check from the monorepo root, 4. Commit and push, 5. Open a PR, Adding a New Package to Metadata, Bootstrap, Build everything (+23 more)

### Community 11 - "Installer UI (TUI)"
Cohesion: 0.11
Nodes (18): DefaultTerminal, Frame, KeyCode, KeyModifiers, Line, App, AppEvent, render_error() (+10 more)

### Community 12 - "Flatpak Backend"
Cohesion: 0.08
Nodes (24): Backend Adapters (`cxpkg/src/backend/`), Branding (`branding/`), Centrex Core (`core/`), CentrexOS Architecture, Component Descriptions, Container build, Container Deployment, cxpkg (`cxpkg/`) (+16 more)

### Community 13 - "Disk Discovery"
Cohesion: 0.10
Nodes (21): Immutable Upgrade (A-B Root), Architecture, Build Philosophy, Build stages individually, Build variants, Building the System, CentrexOS, Clean and rebuild (+13 more)

### Community 14 - "Bootloader Install"
Cohesion: 0.11
Nodes (18): squashfs Live System, Building, centrex-installer, Chroot Helper, Dependencies, Deployer, DiskProber, Features (+10 more)

### Community 15 - "Core Bootstrapper"
Cohesion: 0.38
Nodes (15): manage-kernels.sh script, cmd_available(), cmd_default(), cmd_install(), cmd_list(), cmd_prune(), cmd_remove(), cmd_status() (+7 more)

### Community 16 - "Locale & Timezone Config"
Cohesion: 0.12
Nodes (15): API call mode, API Protocol, CoreBootstrapper, Building, centrex_core, CLI, Commands, Daemon mode (+7 more)

### Community 17 - "Kernel Patches & Series"
Cohesion: 0.09
Nodes (25): Adding a New Series, AppArmor (MAC), BBRv3 TCP Congestion, BORE Scheduler, Build, centrex-kernel, Clean, Config Design Decisions (+17 more)

### Community 18 - "Package Format Translator"
Cohesion: 0.14
Nodes (18): Box, main(), Error, api_call(), ApiResponse, detect_package_manager(), dispatch(), euid() (+10 more)

### Community 19 - "Dependency Resolver"
Cohesion: 0.13
Nodes (16): cxpkg, ResolutionPlan, Resolver Engine, Adding a Package, Alias Resolution, aliases.json, centrex-metadata, Creating a new category file (+8 more)

### Community 20 - "Filesystem Table Generator"
Cohesion: 0.19
Nodes (5): Conventional Commits Style, Getting Started Guide, CentrexOS Documentation, Index, Quick Reference

### Community 21 - "cxpkg CLI"
Cohesion: 0.50
Nodes (3): Cli, Commands, ConfigAction

### Community 22 - "Installer Config Model"
Cohesion: 0.47
Nodes (11): release.sh script, build_container_release(), build_release(), bump_cargo_versions(), error(), info(), ok(), package_release() (+3 more)

### Community 23 - "cxpkg Error Types"
Cohesion: 0.47
Nodes (9): build-kernel.sh script, apply_patches_to_tree(), build_series(), error(), info(), ok(), require_cmd(), step() (+1 more)

### Community 25 - "KWin Rules Script"
Cohesion: 0.22
Nodes (9): Build System, Cache strategy, CentrexOS Developer Guide, CI Pipeline, Environment variables, Jobs, Make targets, Running CI locally (+1 more)

### Community 29 - "Community 29"
Cohesion: 0.22
Nodes (9): centrex-core verbose logging, Container debugging, cxpkg verbose logging, Debugging, Inspecting the API socket, Installer — run without root, Kernel boot issues, Metadata validation errors (+1 more)

### Community 30 - "Community 30"
Cohesion: 0.50
Nodes (7): check-deps.sh script, check(), check_version(), fail(), ok(), section(), warn()

### Community 31 - "Community 31"
Cohesion: 0.25
Nodes (7): Applying to a Live KDE Session, centrex-desktop-kde, Colour Scheme, Installing the SDDM Theme (system-wide), SDDM Login Screen, Structure, Testing the SDDM theme

### Community 32 - "Community 32"
Cohesion: 0.54
Nodes (6): apply-patches.sh script, apply_dir(), error(), info(), ok(), warn()

### Community 33 - "Community 33"
Cohesion: 0.29
Nodes (5): Commands, Cli, Commands, Cli, Commands

### Community 34 - "Community 34"
Cohesion: 0.52
Nodes (6): bootstrap.sh script, error(), info(), ok(), require_cmd(), warn()

### Community 35 - "Community 35"
Cohesion: 0.33
Nodes (5): Core Command, Example Usage, Packge Manager - CentrexOS, Purpose:, Structure:

### Community 36 - "Community 36"
Cohesion: 0.33
Nodes (6): Building the container image, Calling the API from inside the container, Container Development, Container file layout, Daemon-less mode (CI / rootless), Running locally

### Community 37 - "Community 37"
Cohesion: 0.60
Nodes (5): AptBackend, BackendRegistry, DnfBackend, FlatpakBackend, Backend Trait

### Community 38 - "Community 38"
Cohesion: 0.40
Nodes (5): Adding a new backend, Adding a new CLI command, Config file, cxpkg Internals, cxpkg module map

### Community 39 - "Community 39"
Cohesion: 0.40
Nodes (5): Error handling, Module visibility, Naming, Rust Codebase Standards, Testing

### Community 40 - "Community 40"
Cohesion: 0.70
Nodes (4): ci-check.sh script, fail(), head(), pass()

### Community 41 - "Community 41"
Cohesion: 0.70
Nodes (4): gen-package.sh script, info(), ok(), prompt()

### Community 42 - "Community 42"
Cohesion: 0.83
Nodes (3): info(), ok(), install.sh script

### Community 43 - "Community 43"
Cohesion: 0.50
Nodes (4): Adding a kernel patch, Building the kernel, Kernel Development, Modifying the kernel config

### Community 44 - "Community 44"
Cohesion: 0.50
Nodes (4): Adding a new installer screen, Installer Internals, Installer module map, Testing the TUI without hardware

### Community 45 - "Community 45"
Cohesion: 0.50
Nodes (4): API daemon (`api.rs`), Bootstrapper (`bootstrapper.rs`), Centrex Core Internals, Module map

### Community 46 - "Community 46"
Cohesion: 0.50
Nodes (4): Applying GNOME defaults, Applying KDE defaults to a live system, Desktop Layers, Testing the SDDM theme

### Community 47 - "Community 47"
Cohesion: 0.50
Nodes (4): Release Process, Steps, Version numbering, Who releases

### Community 48 - "Community 48"
Cohesion: 0.67
Nodes (3): Alias resolution, JSON schema, Metadata System

## Knowledge Gaps
- **268 isolated node(s):** `entrypoint.sh script`, `Backend`, `Commands`, `Commands`, `AppEvent` (+263 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CentrexOS Developer Guide` connect `KWin Rules Script` to `Community 36`, `Community 38`, `Community 39`, `Community 43`, `Community 44`, `Community 45`, `Community 46`, `Community 47`, `Community 48`, `Filesystem Table Generator`, `Community 29`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Why does `CentrexOS Monorepo` connect `Desktop Branding & Identity` to `Project Overview & Core`, `Disk Discovery`, `Bootloader Install`, `Locale & Timezone Config`, `Kernel Patches & Series`, `Dependency Resolver`, `Filesystem Table Generator`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **Why does `CentrexOS Documentation` connect `Filesystem Table Generator` to `Desktop Branding & Identity`, `Flatpak Backend`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **What connects `entrypoint.sh script`, `Backend`, `Commands` to the rest of the system?**
  _268 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Desktop Branding & Identity` be split into smaller, more focused modules?**
  _Cohesion score 0.12554112554112554 - nodes in this community are weakly interconnected._
- **Should `Network Configuration` be split into smaller, more focused modules?**
  _Cohesion score 0.04529616724738676 - nodes in this community are weakly interconnected._
- **Should `Package Metadata & Types` be split into smaller, more focused modules?**
  _Cohesion score 0.05789473684210526 - nodes in this community are weakly interconnected._