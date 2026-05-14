# CentrexOS

### Engineered for Flexibility and Performance

CentrexOS is a modern Linux operating system focused on flexibility, performance, and modular architecture.

Built on top of **Centrex Core**, the project aims to provide a unified Linux experience with a custom package orchestration layer capable of integrating multiple package ecosystems such as APT and DNF.

---

# Vision

CentrexOS is designed to bridge the gap between:
- developer freedom
- system performance
- modern package management
- modular infrastructure
- enterprise-grade reliability

The project focuses on creating a flexible Linux platform with:
- unified package abstraction
- modular system components
- reproducible builds
- clean desktop experience
- scalable infrastructure tooling

---

# Core Components

| Component | Description |
|---|---|
| Centrex Core | Base platform and runtime |
| cxpkg | Unified package management layer |
| Resolver Engine | Dependency and backend resolver |
| Backend Adapters | APT, DNF, Flatpak integrations |
| Build System | ISO and root filesystem generation |
| Desktop Layer | Desktop environments and UX |
| Installer | System installation framework |

---

# Architecture

```text
                CentrexOS
                     │
             ┌───────┴────────┐
             │ Centrex Core   │
             └───────┬────────┘
                     │
                 cxpkg
         ┌───────────┴───────────┐
         │                       │
       APT                    DNF
```

---

# Project Goals

- Modern Linux distribution architecture
- Unified package management abstraction
- Modular monorepo development model
- Hybrid backend support
- Optimized desktop and server workflows
- Reproducible and automated builds
- Clean and minimal user experience

---

# Repository Structure

```text
core/          -> Centrex Core platform
backend/       -> Package backend adapters
desktop/       -> Desktop environment layers
kernel/        -> Kernel configuration and patches
installer/     -> Installer framework
repos/         -> Repository metadata and overlays
tooling/       -> Build and CI/CD tooling
build/         -> ISO and root filesystem generation
```

---

# Development Status

CentrexOS is currently in early development.

Initial focus areas:
- repository architecture
- cxpkg prototype
- package metadata abstraction
- ISO build pipeline
- base desktop environment

---

# Planned Features

- Unified package management
- Modular system architecture
- APT and DNF backend support
- Flatpak integration
- Custom software center
- Immutable upgrade support
- Developer-focused tooling
- Modern Wayland desktop

---

# Technology Stack

| Area | Technology |
|---|---|
| Core Language | Rust |
| Build System | Make |
| CI/CD | GitHub Actions |
| Desktop | KDE Plasma |
| Init System | systemd |
| Packaging | APT / DNF |
| Installer | Calamares (initially) |

---

# Build Philosophy

CentrexOS follows:
- simplicity
- modularity
- transparency
- performance
- automation

---

# Contributing

Contributions, ideas, and discussions are welcome.

Project structure and contribution guidelines will evolve as the platform matures.

---

# License

MIT License

---

# Links

- Website: https://centrexos.org
- GitHub: https://github.com/centrexos
