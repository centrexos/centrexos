.PHONY: all build build-core build-cxpkg sync bootstrap iso install clean test fmt check help

CARGO        := cargo
ROOT_DIR     := $(shell pwd)
VERSION      ?= 0.1.0
ARCH         ?= amd64

# ---------------------------------------------------------------------------
all: build

help:
	@echo "CentrexOS build system"
	@echo ""
	@echo "  make build          Build all Rust components"
	@echo "  make build-core     Build centrex-core only"
	@echo "  make build-cxpkg    Build cxpkg only"
	@echo "  make sync           Update git submodules"
	@echo "  make bootstrap      Bootstrap development environment"
	@echo "  make install        Install binaries to /usr/local/bin (requires root)"
	@echo "  make iso            Build bootable ISO"
	@echo "  make test           Run all tests"
	@echo "  make fmt            Format all Rust code"
	@echo "  make check          Run clippy on all Rust code"
	@echo "  make clean          Remove build artifacts"

# ---------------------------------------------------------------------------
sync:
	git submodule update --init --recursive

# ---------------------------------------------------------------------------
build: build-core build-cxpkg

build-core:
	$(CARGO) build --manifest-path core/Cargo.toml --release

build-cxpkg:
	$(CARGO) build --manifest-path cxpkg/Cargo.toml --release

# ---------------------------------------------------------------------------
bootstrap:
	chmod +x scripts/bootstrap.sh
	./scripts/bootstrap.sh

# ---------------------------------------------------------------------------
install: build
	install -m 755 core/target/release/centrex-core  /usr/local/bin/centrex-core
	install -m 755 cxpkg/target/release/cxpkg         /usr/local/bin/cxpkg
	@echo "Installed centrex-core and cxpkg to /usr/local/bin"

# ---------------------------------------------------------------------------
iso:
	chmod +x build/build-iso.sh
	VERSION=$(VERSION) ARCH=$(ARCH) ./build/build-iso.sh

# ---------------------------------------------------------------------------
test:
	$(CARGO) test --manifest-path core/Cargo.toml
	$(CARGO) test --manifest-path cxpkg/Cargo.toml

# ---------------------------------------------------------------------------
fmt:
	$(CARGO) fmt --manifest-path core/Cargo.toml
	$(CARGO) fmt --manifest-path cxpkg/Cargo.toml

# ---------------------------------------------------------------------------
check:
	$(CARGO) clippy --manifest-path core/Cargo.toml -- -D warnings
	$(CARGO) clippy --manifest-path cxpkg/Cargo.toml -- -D warnings

# ---------------------------------------------------------------------------
clean:
	$(CARGO) clean --manifest-path core/Cargo.toml
	$(CARGO) clean --manifest-path cxpkg/Cargo.toml
	rm -rf /tmp/centrexos-build
