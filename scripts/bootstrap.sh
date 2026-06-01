#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

info()  { echo -e "\033[1;34m[bootstrap]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[bootstrap]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[bootstrap]\033[0m $*"; }
error() { echo -e "\033[1;31m[bootstrap]\033[0m $*" >&2; exit 1; }

require_cmd() {
    command -v "$1" &>/dev/null || error "Required tool not found: $1"
}

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
info "Running preflight checks..."
require_cmd git
require_cmd cargo
require_cmd rustup
require_cmd make

RUST_VERSION=$(rustc --version 2>/dev/null | awk '{print $2}')
info "Rust toolchain: $RUST_VERSION"

# ---------------------------------------------------------------------------
# Submodules
# ---------------------------------------------------------------------------
info "Initialising git submodules..."
git -C "$ROOT_DIR" submodule update --init --recursive

# ---------------------------------------------------------------------------
# Build centrex-core
# ---------------------------------------------------------------------------
info "Building centrex-core..."
cargo build --manifest-path "$ROOT_DIR/core/Cargo.toml" --release
ok "centrex-core built: $ROOT_DIR/core/target/release/centrex-core"

# ---------------------------------------------------------------------------
# Build cxpkg
# ---------------------------------------------------------------------------
if [[ -f "$ROOT_DIR/cxpkg/Cargo.toml" ]]; then
    info "Building cxpkg..."
    cargo build --manifest-path "$ROOT_DIR/cxpkg/Cargo.toml" --release
    ok "cxpkg built: $ROOT_DIR/cxpkg/target/release/cxpkg"
else
    warn "cxpkg Cargo.toml not found — skipping"
fi

# ---------------------------------------------------------------------------
# Create directory skeleton
# ---------------------------------------------------------------------------
info "Creating directory skeleton..."
for dir in \
    /opt/centrex_store/lib \
    /opt/centrex_store/lib64 \
    /opt/centrex_store/bin \
    /var/cache/cxpkg \
    /var/lib/cxpkg \
    /etc/cxpkg
do
    mkdir -p "$dir" && info "  created: $dir"
done

# ---------------------------------------------------------------------------
# Install binaries (requires root)
# ---------------------------------------------------------------------------
if [[ "$EUID" -eq 0 ]]; then
    info "Installing binaries to /usr/local/bin..."
    install -m 755 "$ROOT_DIR/core/target/release/centrex-core" /usr/local/bin/centrex-core
    [[ -f "$ROOT_DIR/cxpkg/target/release/cxpkg" ]] && \
        install -m 755 "$ROOT_DIR/cxpkg/target/release/cxpkg" /usr/local/bin/cxpkg
    ok "Binaries installed."
else
    warn "Not running as root — skipping system-wide installation."
    warn "Run 'sudo make install' to install system-wide."
fi

ok "Bootstrap complete."
