#!/usr/bin/env bash
# CentrexOS ISO build pipeline
#
# Stages:
#   1. Preflight       — verify tools and pre-built artifacts
#   2. Base rootfs     — debootstrap Debian stable
#   3. Kernel          — install custom kernel from kernel/output/<SERIES>/
#   4. Binaries        — install centrex-core, cxpkg, centrex-installer
#   5. Config layer    — cxpkg config, os-release, fstab skeleton
#   6. Desktop layer   — KDE or GNOME packages + defaults
#   7. Branding        — Plymouth, GRUB theme, logo
#   8. Squash          — compress rootfs with mksquashfs
#   9. ISO assembly    — GRUB bootloader + xorriso
#
# Usage:
#   sudo ./build/build-iso.sh
#   sudo VERSION=0.2.0 SERIES=7.0 DESKTOP=gnome ./build/build-iso.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

VERSION="${VERSION:-0.1.0}"
ARCH="${ARCH:-amd64}"
DESKTOP="${DESKTOP:-kde}"
SERIES="${SERIES:-$(jq -r .default "$ROOT_DIR/kernel/versions.json" 2>/dev/null || echo 6.12)}"
JOBS="${JOBS:-$(nproc)}"
LEGACY_BIOS="${LEGACY_BIOS:-true}"

WORK_DIR="${WORK_DIR:-/tmp/centrexos-build}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/releases}"
ROOTFS="$WORK_DIR/rootfs"
ISO_STAGING="$WORK_DIR/iso"
ISO_NAME="centrexos-${VERSION}-${ARCH}.iso"
ISO_LABEL="CentrexOS"

DEBIAN_MIRROR="${DEBIAN_MIRROR:-http://deb.debian.org/debian}"

# ── helpers ──────────────────────────────────────────────────────────────────
info()  { echo -e "\033[1;34m[iso]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[iso]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[iso]\033[0m $*"; }
error() { echo -e "\033[1;31m[iso]\033[0m $*" >&2; exit 1; }
step()  { echo -e "\n\033[1;36m── Stage $1: $2 ──\033[0m"; }

require_cmd() { command -v "$1" &>/dev/null || error "Missing: $1"; }
require_file() { [[ -f "$1" ]] || error "Required file not found: $1"; }

chroot_run() { chroot "$ROOTFS" env DEBIAN_FRONTEND=noninteractive "$@"; }

# ── Stage 1: Preflight ───────────────────────────────────────────────────────
step 1 "Preflight"

[[ "$EUID" -eq 0 ]] || error "ISO build requires root. Run: sudo make iso"

for cmd in debootstrap mksquashfs xorriso grub-mkrescue cargo jq; do
    require_cmd "$cmd"
done

# Detect GRUB platform module availability for hybrid ISO
GRUB_I386_PC=/usr/lib/grub/i386-pc
GRUB_X86_EFI=/usr/lib/grub/x86_64-efi

if $LEGACY_BIOS; then
    if [[ -d "$GRUB_I386_PC" ]]; then
        info "BIOS boot:   enabled  ($GRUB_I386_PC)"
    else
        warn "grub-pc-bin modules missing at $GRUB_I386_PC — legacy BIOS boot disabled"
        warn "  To enable: apt install grub-pc-bin   OR   dnf install grub2-pc"
        LEGACY_BIOS=false
    fi
else
    info "BIOS boot:   disabled (LEGACY_BIOS=false)"
fi

if [[ -d "$GRUB_X86_EFI" ]]; then
    info "EFI boot:    enabled  ($GRUB_X86_EFI)"
else
    warn "grub-efi-amd64-bin modules missing at $GRUB_X86_EFI — UEFI boot may be unavailable"
    warn "  To enable: apt install grub-efi-amd64-bin mtools   OR   dnf install grub2-efi-x64"
fi

info "Version:  $VERSION"
info "Arch:     $ARCH"
info "Kernel:   series $SERIES"
info "Desktop:  $DESKTOP"
info "BIOS:     $LEGACY_BIOS"
info "Work dir: $WORK_DIR"

# Verify pre-built Rust artifacts
require_file "$ROOT_DIR/core/target/release/centrex-core"
require_file "$ROOT_DIR/cxpkg/target/release/cxpkg"
require_file "$ROOT_DIR/installer/target/release/centrex-installer"

# Locate built kernel for this series
KERNEL_BUILD_JSON="$ROOT_DIR/kernel/output/$SERIES/build.json"
if [[ -f "$KERNEL_BUILD_JSON" ]]; then
    KVER=$(jq -r .kver "$KERNEL_BUILD_JSON")
    KERNEL_VMLINUZ="$ROOT_DIR/kernel/output/$SERIES/boot/vmlinuz-${KVER}"
    KERNEL_SYSMAP="$ROOT_DIR/kernel/output/$SERIES/boot/System.map-${KVER}"
    KERNEL_MODULES="$ROOT_DIR/kernel/output/$SERIES/modules/lib/modules/${KVER}"
    require_file "$KERNEL_VMLINUZ"
    info "Kernel:   $KVER  ($SERIES)"
    USE_CUSTOM_KERNEL=true
else
    warn "No pre-built kernel found for series $SERIES — using debootstrap kernel"
    warn "Run 'make kernel SERIES=$SERIES' first for a CentrexOS-tuned kernel"
    USE_CUSTOM_KERNEL=false
fi

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

# ── Stage 2: Base rootfs ─────────────────────────────────────────────────────
step 2 "Base rootfs (debootstrap)"

if [[ -d "$ROOTFS/usr" ]]; then
    warn "Existing rootfs found — skipping debootstrap (delete $ROOTFS to rebuild)"
else
    rm -rf "$ROOTFS"
    mkdir -p "$ROOTFS"
    info "Bootstrapping Debian stable ($ARCH) from $DEBIAN_MIRROR ..."
    debootstrap --arch="$ARCH" stable "$ROOTFS" "$DEBIAN_MIRROR"
fi
ok "Base rootfs ready."

# ── Stage 3: Kernel ──────────────────────────────────────────────────────────
step 3 "Kernel installation"

if $USE_CUSTOM_KERNEL; then
    info "Installing custom kernel $KVER ..."
    install -m 644 "$KERNEL_VMLINUZ" "$ROOTFS/boot/vmlinuz-${KVER}"
    install -m 644 "$KERNEL_SYSMAP"  "$ROOTFS/boot/System.map-${KVER}"

    info "Installing kernel modules ..."
    mkdir -p "$ROOTFS/lib/modules"
    cp -r "$KERNEL_MODULES" "$ROOTFS/lib/modules/"

    info "Generating initramfs for $KVER ..."
    mount --bind /dev     "$ROOTFS/dev"
    mount --bind /dev/pts "$ROOTFS/dev/pts"
    mount --bind /proc    "$ROOTFS/proc"
    mount --bind /sys     "$ROOTFS/sys"

    chroot_run update-initramfs -c -k "$KVER" || \
        warn "update-initramfs failed — initrd may be missing"

    umount -l "$ROOTFS/sys"  2>/dev/null || true
    umount -l "$ROOTFS/proc" 2>/dev/null || true
    umount -l "$ROOTFS/dev/pts" 2>/dev/null || true
    umount -l "$ROOTFS/dev"  2>/dev/null || true

    ok "Custom kernel $KVER installed."
else
    # Install a stock kernel from the mirror as fallback
    info "Installing stock kernel from mirror ..."
    mount --bind /dev     "$ROOTFS/dev"
    mount --bind /proc    "$ROOTFS/proc"
    mount --bind /sys     "$ROOTFS/sys"

    chroot_run apt-get install -y --no-install-recommends \
        linux-image-amd64 initramfs-tools

    umount -l "$ROOTFS/sys"  2>/dev/null || true
    umount -l "$ROOTFS/proc" 2>/dev/null || true
    umount -l "$ROOTFS/dev"  2>/dev/null || true

    ok "Stock kernel installed."
fi

# ── Stage 4: Binaries ────────────────────────────────────────────────────────
step 4 "CentrexOS binaries"

mkdir -p "$ROOTFS/usr/local/bin"
install -m 755 "$ROOT_DIR/core/target/release/centrex-core"           "$ROOTFS/usr/local/bin/centrex-core"
install -m 755 "$ROOT_DIR/cxpkg/target/release/cxpkg"                 "$ROOTFS/usr/local/bin/cxpkg"
install -m 755 "$ROOT_DIR/installer/target/release/centrex-installer"  "$ROOTFS/usr/local/bin/centrex-installer"
ok "Binaries installed."

# ── Stage 5: Config layer ────────────────────────────────────────────────────
step 5 "Config layer"

# OS identity
cat > "$ROOTFS/etc/os-release" <<EOF
NAME="CentrexOS"
ID=centrexos
PRETTY_NAME="CentrexOS $VERSION"
VERSION="$VERSION"
VERSION_ID="$VERSION"
HOME_URL="https://centrexos.org"
SUPPORT_URL="https://github.com/centrexos"
BUG_REPORT_URL="https://github.com/centrexos/centrexos/issues"
LOGO=centrexos-logo
EOF

# Machine-id — cleared so systemd generates a unique one at first boot
echo > "$ROOTFS/etc/machine-id"

# cxpkg config
mkdir -p "$ROOTFS/etc/cxpkg" "$ROOTFS/var/cache/cxpkg" \
         "$ROOTFS/var/lib/cxpkg" "$ROOTFS/opt/centrex_store"
install -m 644 /dev/stdin "$ROOTFS/etc/cxpkg/config.toml" <<'EOF'
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

# Kernel modules load list
install -m 644 "$ROOT_DIR/kernel/modules/centrex-modules.conf" \
    "$ROOTFS/etc/modules-load.d/centrex.conf"

# Package metadata
mkdir -p "$ROOTFS/usr/share/centrexos"
cp -r "$ROOT_DIR/metadata" "$ROOTFS/usr/share/centrexos/metadata"

ok "Config layer applied."

# ── Stage 6: Desktop layer ───────────────────────────────────────────────────
step 6 "Desktop layer ($DESKTOP)"

mount --bind /dev  "$ROOTFS/dev"
mount --bind /proc "$ROOTFS/proc"
mount --bind /sys  "$ROOTFS/sys"

chroot_run apt-get update -qq

case "$DESKTOP" in
    kde)
        info "Installing KDE Plasma desktop ..."
        chroot_run apt-get install -y --no-install-recommends \
            plasma-desktop plasma-nm plasma-pa sddm sddm-theme-breeze \
            kde-standard dolphin konsole kwrite \
            papirus-icon-theme fonts-noto fonts-noto-mono

        # Apply KDE defaults
        mkdir -p "$ROOTFS/etc/skel/.config"
        cp "$ROOT_DIR/desktop-kde/defaults/kdeglobals"          "$ROOTFS/etc/skel/.config/kdeglobals"
        cp "$ROOT_DIR/desktop-kde/defaults/plasma-workspace.conf" "$ROOTFS/etc/skel/.config/plasma-workspace.conf"

        mkdir -p "$ROOTFS/usr/share/color-schemes"
        cp "$ROOT_DIR/desktop-kde/themes/colors/CentrexDark.colors" \
            "$ROOTFS/usr/share/color-schemes/"

        mkdir -p "$ROOTFS/usr/share/sddm/themes"
        cp -r "$ROOT_DIR/desktop-kde/sddm/centrex-sddm" \
            "$ROOTFS/usr/share/sddm/themes/"

        mkdir -p "$ROOTFS/etc/sddm.conf.d"
        printf '[Theme]\nCurrent=centrex-sddm\n' > \
            "$ROOTFS/etc/sddm.conf.d/centrexos.conf"

        chroot_run systemctl enable sddm
        ;;
    gnome)
        info "Installing GNOME desktop ..."
        chroot_run apt-get install -y --no-install-recommends \
            gnome-shell gnome-session gnome-control-center gnome-tweaks \
            gdm3 nautilus gnome-terminal gedit \
            adwaita-icon-theme papirus-icon-theme \
            fonts-noto fonts-noto-mono

        # Apply GNOME gsettings overrides
        mkdir -p "$ROOTFS/usr/share/glib-2.0/schemas"
        cp "$ROOT_DIR/desktop-gnome/gsettings/centrex.gschema.override" \
            "$ROOTFS/usr/share/glib-2.0/schemas/30_centrexos.gschema.override"
        chroot_run glib-compile-schemas /usr/share/glib-2.0/schemas/

        # MIME defaults
        mkdir -p "$ROOTFS/etc/xdg"
        cp "$ROOT_DIR/desktop-gnome/defaults/default-apps" \
            "$ROOTFS/etc/xdg/mimeapps.list"

        chroot_run systemctl enable gdm
        ;;
    minimal)
        info "Minimal install — no desktop environment."
        ;;
    *)
        error "Unknown DESKTOP value: $DESKTOP  (use kde | gnome | minimal)"
        ;;
esac

chroot_run apt-get install -y --no-install-recommends \
    systemd systemd-sysv network-manager sudo \
    bash-completion man-db locales tzdata \
    flatpak

chroot_run systemctl enable NetworkManager

umount -l "$ROOTFS/sys"  2>/dev/null || true
umount -l "$ROOTFS/proc" 2>/dev/null || true
umount -l "$ROOTFS/dev"  2>/dev/null || true

ok "Desktop layer ($DESKTOP) applied."

# ── Stage 7: Branding ────────────────────────────────────────────────────────
step 7 "Branding"

mkdir -p "$ROOTFS/usr/share/centrexos"
cp "$ROOT_DIR/branding/logo/centrexos.svg"       "$ROOTFS/usr/share/centrexos/logo.svg"
cp "$ROOT_DIR/branding/logo/centrexos-white.svg"  "$ROOTFS/usr/share/centrexos/logo-white.svg"

# Plymouth
PLYMOUTH_THEME_DIR="$ROOTFS/usr/share/plymouth/themes/centrex-splash"
mkdir -p "$PLYMOUTH_THEME_DIR"
cp -r "$ROOT_DIR/branding/plymouth/centrex-splash/"* "$PLYMOUTH_THEME_DIR/"

# GRUB theme
GRUB_THEME_DIR="$ROOTFS/usr/share/grub/themes/centrex"
mkdir -p "$GRUB_THEME_DIR"
cp -r "$ROOT_DIR/branding/grub/centrex-theme/"* "$GRUB_THEME_DIR/"

# /etc/default/grub
cat > "$ROOTFS/etc/default/grub" <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="CentrexOS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GRUB_THEME="/usr/share/grub/themes/centrex/theme.txt"
GRUB_GFXMODE="auto"
GRUB_GFXPAYLOAD_LINUX="keep"
EOF

ok "Branding applied."

# ── Stage 8: Squashfs ────────────────────────────────────────────────────────
step 8 "Compress rootfs (squashfs)"

SQUASH_DIR="$ISO_STAGING/live"
mkdir -p "$SQUASH_DIR"

info "Compressing rootfs — this takes several minutes ..."
mksquashfs "$ROOTFS" "$SQUASH_DIR/filesystem.squashfs" \
    -comp zstd -Xcompression-level 19 \
    -noappend \
    -wildcards \
    -e boot \
    -e proc \
    -e sys \
    -e dev

SQUASH_SIZE=$(du -sh "$SQUASH_DIR/filesystem.squashfs" | cut -f1)
ok "Squashfs created: $SQUASH_SIZE"

# ── Stage 9: ISO assembly ────────────────────────────────────────────────────
step 9 "Assemble bootable ISO"

# Find kernel and initrd in the rootfs
if $USE_CUSTOM_KERNEL; then
    LIVE_VMLINUZ="$ROOTFS/boot/vmlinuz-${KVER}"
    LIVE_INITRD="$ROOTFS/boot/initrd.img-${KVER}"
else
    LIVE_VMLINUZ=$(find "$ROOTFS/boot" -name "vmlinuz-*" -not -name "*.old" | sort | tail -1)
    LIVE_INITRD=$(find  "$ROOTFS/boot" -name "initrd.img-*" | sort | tail -1)
fi

[[ -f "$LIVE_VMLINUZ" ]] || error "vmlinuz not found in $ROOTFS/boot"
[[ -f "$LIVE_INITRD"  ]] || error "initrd not found in $ROOTFS/boot"

cp "$LIVE_VMLINUZ" "$SQUASH_DIR/vmlinuz"
cp "$LIVE_INITRD"  "$SQUASH_DIR/initrd"

# GRUB config for the live ISO
mkdir -p "$ISO_STAGING/boot/grub"
cat > "$ISO_STAGING/boot/grub/grub.cfg" <<EOF
set timeout=5
set default=0

insmod all_video
insmod gfxterm
insmod png

if [ -f /boot/grub/themes/centrex/theme.txt ]; then
    set theme=/boot/grub/themes/centrex/theme.txt
    export theme
fi

menuentry "CentrexOS $VERSION — Install" {
    linux  /live/vmlinuz boot=live components quiet splash
    initrd /live/initrd
}

menuentry "CentrexOS $VERSION — Try without installing" {
    linux  /live/vmlinuz boot=live components quiet splash toram
    initrd /live/initrd
}

menuentry "CentrexOS $VERSION — Safe mode (nomodeset)" {
    linux  /live/vmlinuz boot=live components nomodeset
    initrd /live/initrd
}

menuentry "Boot from first hard disk" {
    insmod chain
    chainloader +1
}
EOF

# GRUB theme into ISO staging
mkdir -p "$ISO_STAGING/boot/grub/themes"
cp -r "$ROOT_DIR/branding/grub/centrex-theme" "$ISO_STAGING/boot/grub/themes/centrex"

# Build the ISO
info "Running grub-mkrescue ..."
grub-mkrescue \
    --output="$OUTPUT_DIR/$ISO_NAME" \
    "$ISO_STAGING" \
    -- \
    -volid "$ISO_LABEL" \
    -r

# ── Done ─────────────────────────────────────────────────────────────────────
ISO_SIZE=$(du -sh "$OUTPUT_DIR/$ISO_NAME" | cut -f1)
echo ""
ok "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "  ISO ready: $OUTPUT_DIR/$ISO_NAME  ($ISO_SIZE)"
ok "  Version:   $VERSION   Arch: $ARCH"
ok "  Kernel:    ${KVER:-stock}   Desktop: $DESKTOP"
ok "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
info "Test in QEMU (legacy BIOS):"
info "  qemu-system-x86_64 -m 4G -cdrom $OUTPUT_DIR/$ISO_NAME -boot d -enable-kvm"
info "Test in QEMU (UEFI — requires OVMF):"
info "  qemu-system-x86_64 -m 4G -cdrom $OUTPUT_DIR/$ISO_NAME -boot d -enable-kvm \\"
info "    -bios /usr/share/OVMF/OVMF_CODE.fd"
