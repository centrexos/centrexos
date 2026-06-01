#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

WORK_DIR="${WORK_DIR:-/tmp/centrexos-build}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/releases}"
ISO_LABEL="${ISO_LABEL:-CentrexOS}"
ARCH="${ARCH:-amd64}"
VERSION="${VERSION:-0.1.0}"
ISO_NAME="centrexos-${VERSION}-${ARCH}.iso"

info()  { echo -e "\033[1;34m[iso-build]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[iso-build]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[iso-build]\033[0m $*"; }
error() { echo -e "\033[1;31m[iso-build]\033[0m $*" >&2; exit 1; }

require_cmd() {
    command -v "$1" &>/dev/null || error "Required tool not found: $1. Install it and retry."
}

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
[[ "$EUID" -eq 0 ]] || error "ISO build must run as root."

require_cmd debootstrap
require_cmd xorriso
require_cmd mksquashfs
require_cmd grub-mkrescue
require_cmd cargo

info "Building CentrexOS $VERSION ($ARCH)"
info "Work dir:   $WORK_DIR"
info "Output dir: $OUTPUT_DIR"

# ---------------------------------------------------------------------------
# Stage 1 — Build tooling
# ---------------------------------------------------------------------------
info "Stage 1: Building Rust binaries..."
cargo build --manifest-path "$ROOT_DIR/core/Cargo.toml"   --release
cargo build --manifest-path "$ROOT_DIR/cxpkg/Cargo.toml"  --release
ok "Binaries compiled."

# ---------------------------------------------------------------------------
# Stage 2 — Bootstrap base rootfs
# ---------------------------------------------------------------------------
ROOTFS="$WORK_DIR/rootfs"
info "Stage 2: Bootstrapping base system into $ROOTFS..."
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"

# Use debootstrap for a Debian-based base. Swap mirror as needed.
MIRROR="${DEBIAN_MIRROR:-http://deb.debian.org/debian}"
debootstrap --arch="$ARCH" stable "$ROOTFS" "$MIRROR"
ok "Base rootfs ready."

# ---------------------------------------------------------------------------
# Stage 3 — Install CentrexOS layer
# ---------------------------------------------------------------------------
info "Stage 3: Installing CentrexOS layer..."

# Install binaries
install -m 755 "$ROOT_DIR/core/target/release/centrex-core"  "$ROOTFS/usr/local/bin/centrex-core"
install -m 755 "$ROOT_DIR/cxpkg/target/release/cxpkg"        "$ROOTFS/usr/local/bin/cxpkg"

# Write OS identity
cat > "$ROOTFS/etc/os-release" <<'EOF'
NAME="CentrexOS"
ID=centrexos
PRETTY_NAME="CentrexOS 0.1.0"
VERSION="0.1.0"
VERSION_ID="0.1.0"
HOME_URL="https://centrexos.org"
SUPPORT_URL="https://github.com/centrexos"
BUG_REPORT_URL="https://github.com/centrexos/centrexos/issues"
EOF

# Create cxpkg directory structure
for dir in /etc/cxpkg /var/cache/cxpkg /var/lib/cxpkg /opt/centrex_store; do
    mkdir -p "$ROOTFS/$dir"
done

# Write default cxpkg config
cat > "$ROOTFS/etc/cxpkg/config.toml" <<'EOF'
[backends]
apt_enabled     = true
dnf_enabled     = false
flatpak_enabled = true
priority        = ["apt", "flatpak"]

[resolver]
allow_downgrades    = false
auto_remove_orphans = false

[cache]
dir          = "/var/cache/cxpkg"
max_age_days = 7
EOF

ok "CentrexOS layer installed."

# ---------------------------------------------------------------------------
# Stage 4 — Squash rootfs
# ---------------------------------------------------------------------------
SQUASH="$WORK_DIR/iso/live/filesystem.squashfs"
info "Stage 4: Compressing rootfs with squashfs..."
mkdir -p "$(dirname "$SQUASH")"
mksquashfs "$ROOTFS" "$SQUASH" -comp xz -noappend -e boot
ok "Squashfs created: $SQUASH"

# ---------------------------------------------------------------------------
# Stage 5 — Assemble ISO
# ---------------------------------------------------------------------------
ISO_STAGING="$WORK_DIR/iso"
info "Stage 5: Assembling bootable ISO..."

# Copy kernel and initrd from rootfs
VMLINUZ=$(find "$ROOTFS/boot" -name "vmlinuz-*" | sort | tail -1)
INITRD=$(find "$ROOTFS/boot"  -name "initrd.img-*" | sort | tail -1)
[[ -n "$VMLINUZ" ]] || error "No vmlinuz found in rootfs/boot"
[[ -n "$INITRD"  ]] || error "No initrd found in rootfs/boot"

mkdir -p "$ISO_STAGING/boot/grub"
cp "$VMLINUZ" "$ISO_STAGING/live/vmlinuz"
cp "$INITRD"  "$ISO_STAGING/live/initrd"

cat > "$ISO_STAGING/boot/grub/grub.cfg" <<EOF
set timeout=5
set default=0

menuentry "CentrexOS $VERSION" {
    linux  /live/vmlinuz boot=live quiet splash
    initrd /live/initrd
}

menuentry "CentrexOS $VERSION (safe mode)" {
    linux  /live/vmlinuz boot=live nomodeset
    initrd /live/initrd
}
EOF

mkdir -p "$OUTPUT_DIR"
grub-mkrescue -o "$OUTPUT_DIR/$ISO_NAME" "$ISO_STAGING" -- -volid "$ISO_LABEL"
ok "ISO created: $OUTPUT_DIR/$ISO_NAME"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
ISO_SIZE=$(du -sh "$OUTPUT_DIR/$ISO_NAME" | cut -f1)
ok "Build complete — $ISO_NAME ($ISO_SIZE)"
