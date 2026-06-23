# CentrexOS top-level build system
#
# Full system build (recommended first run):
#   make dist
#
# Quick targets:
#   make build          Rust components only
#   make kernel         Kernel only (default series)
#   make iso            ISO only (uses pre-built artifacts)
#   make help           Show all targets

.PHONY: all dist release \
        build build-core build-cxpkg build-installer \
        kernel kernel-all kernel-list kernel-status kernel-install kernel-prune \
        iso \
        container container-release \
        install install-bins install-kernel \
        test fmt check check-deps \
        bootstrap sync \
        clean clean-rust clean-kernel clean-iso \
        help

CARGO    := cargo
ROOT_DIR := $(shell pwd)

VERSION  ?= 0.1.0
ARCH     ?= amd64
DESKTOP  ?= kde
SERIES   ?= $(shell jq -r .default kernel/versions.json 2>/dev/null || echo 6.12)
KEEP     ?= 2
JOBS     ?= $(shell nproc)

# Paths to built artifacts (used by ISO stage)
CORE_BIN       := core/target/release/centrex-core
CXPKG_BIN      := cxpkg/target/release/cxpkg
INSTALLER_BIN  := installer/target/release/centrex-installer
KERNEL_VMLINUZ := kernel/output/$(SERIES)/boot/vmlinuz-$(shell \
    cat kernel/output/$(SERIES)/build.json 2>/dev/null | jq -r .kver 2>/dev/null || echo "$(SERIES).0-centrex")

# ---------------------------------------------------------------------------
# Default: show help (never silently build everything on bare `make`)
# ---------------------------------------------------------------------------
all: help

# ---------------------------------------------------------------------------
# DIST — full system build, ordered pipeline
# ---------------------------------------------------------------------------
dist: check-deps sync build kernel iso
	@echo ""
	@echo "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo "\033[1;32m  CentrexOS $(VERSION) build complete\033[0m"
	@echo "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo ""
	@echo "  ISO:  releases/centrexos-$(VERSION)-$(ARCH).iso"
	@echo "  Kernel series: $(SERIES)"
	@echo "  Desktop: $(DESKTOP)"
	@echo ""

# dist + run release script (version bump, tag, tarball)
release: dist
	./tooling/scripts/release.sh $(VERSION)

# ---------------------------------------------------------------------------
# Stage 1 — Dependency check
# ---------------------------------------------------------------------------
check-deps:
	@chmod +x scripts/check-deps.sh
	@scripts/check-deps.sh --iso --kernel

# ---------------------------------------------------------------------------
# Stage 2 — Sync submodules
# ---------------------------------------------------------------------------
sync:
	git submodule update --init --recursive

# ---------------------------------------------------------------------------
# Stage 3 — Bootstrap (first-time environment setup)
# ---------------------------------------------------------------------------
bootstrap:
	@chmod +x scripts/bootstrap.sh
	@./scripts/bootstrap.sh

# ---------------------------------------------------------------------------
# Stage 4 — Rust components
# ---------------------------------------------------------------------------
build: build-core build-cxpkg build-installer

build-core:
	@echo "\033[1;34m[build]\033[0m centrex-core..."
	$(CARGO) build --manifest-path core/Cargo.toml --release

build-cxpkg:
	@echo "\033[1;34m[build]\033[0m cxpkg..."
	$(CARGO) build --manifest-path cxpkg/Cargo.toml --release

build-installer:
	@echo "\033[1;34m[build]\033[0m centrex-installer..."
	$(CARGO) build --manifest-path installer/Cargo.toml --release

# ---------------------------------------------------------------------------
# Stage 5 — Kernel
# ---------------------------------------------------------------------------
kernel:
	$(MAKE) -C kernel build SERIES=$(SERIES) JOBS=$(JOBS)

kernel-all:
	$(MAKE) -C kernel build-all JOBS=$(JOBS)

kernel-list:
	$(MAKE) -C kernel list

kernel-status:
	$(MAKE) -C kernel status

kernel-install:
	$(MAKE) -C kernel install SERIES=$(SERIES) JOBS=$(JOBS)

kernel-prune:
	$(MAKE) -C kernel prune KEEP=$(KEEP)

# ---------------------------------------------------------------------------
# Stage 6 — ISO  (requires root via sudo)
# ---------------------------------------------------------------------------
iso:
	@chmod +x build/build-iso.sh
	@sudo VERSION=$(VERSION) ARCH=$(ARCH) DESKTOP=$(DESKTOP) SERIES=$(SERIES) \
	    ./build/build-iso.sh

# ---------------------------------------------------------------------------
# Container image (no root required — uses docker build)
# ---------------------------------------------------------------------------
container: build
	@chmod +x build/build-container.sh
	@VERSION=$(VERSION) ARCH=$(ARCH) OUTPUT_DIR=$(ROOT_DIR)/releases \
	    ./build/build-container.sh

# dist + container release (ISO + container image in one pass)
container-release: dist container
	@echo ""
	@echo "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo "\033[1;32m  CentrexOS $(VERSION) — full release complete\033[0m"
	@echo "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo "  ISO:       releases/centrexos-$(VERSION)-$(ARCH).iso"
	@echo "  Container: releases/centrexos-$(VERSION)-container.tar.gz"
	@echo ""

# ---------------------------------------------------------------------------
# Install to live system (requires root)
# ---------------------------------------------------------------------------
install: install-bins

install-bins: build
	sudo install -m 755 $(CORE_BIN)      /usr/local/bin/centrex-core
	sudo install -m 755 $(CXPKG_BIN)     /usr/local/bin/cxpkg
	sudo install -m 755 $(INSTALLER_BIN) /usr/local/bin/centrex-installer
	@echo "Installed binaries to /usr/local/bin"

install-kernel:
	sudo $(MAKE) -C kernel install SERIES=$(SERIES) JOBS=$(JOBS)

# ---------------------------------------------------------------------------
# Quality checks
# ---------------------------------------------------------------------------
test:
	$(CARGO) test --manifest-path core/Cargo.toml
	$(CARGO) test --manifest-path cxpkg/Cargo.toml

fmt:
	$(CARGO) fmt --manifest-path core/Cargo.toml
	$(CARGO) fmt --manifest-path cxpkg/Cargo.toml
	$(CARGO) fmt --manifest-path installer/Cargo.toml

check:
	$(CARGO) clippy --manifest-path core/Cargo.toml      -- -D warnings
	$(CARGO) clippy --manifest-path cxpkg/Cargo.toml     -- -D warnings
	$(CARGO) clippy --manifest-path installer/Cargo.toml -- -D warnings

ci: fmt check test
	@chmod +x tooling/scripts/ci-check.sh
	@./tooling/scripts/ci-check.sh

# ---------------------------------------------------------------------------
# Clean
# ---------------------------------------------------------------------------
clean: clean-rust clean-kernel clean-iso

clean-rust:
	$(CARGO) clean --manifest-path core/Cargo.toml
	$(CARGO) clean --manifest-path cxpkg/Cargo.toml
	$(CARGO) clean --manifest-path installer/Cargo.toml

clean-kernel:
	$(MAKE) -C kernel clean

clean-iso:
	rm -rf /tmp/centrexos-build
	@echo "ISO work directory removed."

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
help:
	@echo ""
	@echo "  \033[1;36mCentrexOS Build System\033[0m"
	@echo "  ─────────────────────────────────────────────────────────────"
	@echo ""
	@echo "  \033[1mFull system build:\033[0m"
	@echo "    make dist                   Full pipeline: deps → sync → build → kernel → ISO  [needs sudo]"
	@echo "    make dist  SERIES=7.0       Use 7.0 testing kernel"
	@echo "    make dist  DESKTOP=gnome    Build GNOME desktop variant"
	@echo "    make dist  VERSION=0.2.0    Tag the release with a version"
	@echo "    make release VERSION=0.2.0  dist + release packaging + git tag"
	@echo ""
	@echo "  \033[1mIndividual stages:\033[0m"
	@echo "    make check-deps             Verify all required tools are installed"
	@echo "    make sync                   Update git submodules"
	@echo "    make bootstrap              First-time environment setup"
	@echo "    make build                  Build all Rust components"
	@echo "    make build-core             Build centrex-core only"
	@echo "    make build-cxpkg            Build cxpkg only"
	@echo "    make build-installer        Build centrex-installer only"
	@echo "    make kernel                 Build kernel (series: $(SERIES))"
	@echo "    make kernel  SERIES=7.0     Build a specific kernel series"
	@echo "    make kernel-all             Build every kernel series"
	@echo "    make iso                    Assemble ISO from pre-built artifacts  [sudo inside]"
	@echo ""
	@echo "  \033[1mContainer (no root required):\033[0m"
	@echo "    make container              Build Docker image → releases/*.tar.gz"
	@echo "    make container VERSION=0.3.0  Tag the container image"
	@echo "    make container-release      dist + container in one pass"
	@echo ""
	@echo "  \033[1mSystem install (sudo inside):\033[0m"
	@echo "    make install                Install binaries to /usr/local/bin"
	@echo "    make install-kernel         Build + install kernel to /boot"
	@echo "    make kernel-prune           Remove old kernels (keep=$(KEEP))"
	@echo ""
	@echo "  \033[1mQuality:\033[0m"
	@echo "    make test                   Run all unit tests"
	@echo "    make fmt                    Format all Rust code"
	@echo "    make check                  clippy (zero warnings)"
	@echo "    make ci                     Full local CI check"
	@echo ""
	@echo "  \033[1mMaintenance:\033[0m"
	@echo "    make clean                  Remove all build artifacts"
	@echo "    make clean-rust             Remove Rust target/ directories"
	@echo "    make clean-kernel           Remove kernel output/"
	@echo "    make clean-iso              Remove ISO work directory"
	@echo "    make kernel-list            List available kernel series"
	@echo "    make kernel-status          Installed vs available kernels"
	@echo ""
	@echo "  \033[1mVariables:\033[0m"
	@echo "    VERSION=$(VERSION)  ARCH=$(ARCH)  SERIES=$(SERIES)  DESKTOP=$(DESKTOP)  JOBS=$(JOBS)"
	@echo ""
