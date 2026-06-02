#!/usr/bin/env bash
# Verify that every tool required to build CentrexOS is installed.
# Exits 0 if all required tools are present, 1 if any are missing.
# Run with --iso to also check ISO-specific tools.
# Run with --kernel to also check kernel build tools.
set -euo pipefail

CHECK_ISO=false
CHECK_KERNEL=false

for arg in "$@"; do
    case "$arg" in
        --iso)    CHECK_ISO=true ;;
        --kernel) CHECK_KERNEL=true ;;
        --all)    CHECK_ISO=true; CHECK_KERNEL=true ;;
    esac
done

PASS=0
FAIL=0
WARN=0

ok()      { echo -e "  \033[1;32m✓\033[0m $1"; PASS=$((PASS+1)); }
fail()    { echo -e "  \033[1;31m✗\033[0m $1${2:+  ← $2}"; FAIL=$((FAIL+1)); }
warn()    { echo -e "  \033[1;33m⚠\033[0m $1${2:+  ← $2}"; WARN=$((WARN+1)); }
# NOTE: deliberately not named "head" — that would shadow /usr/bin/head
section() { echo -e "\n\033[1;36m── $1 ──\033[0m"; }

check() {
    local cmd="$1" pkg_apt="${2:-$1}" pkg_dnf="${3:-$1}" required="${4:-required}"
    if command -v "$cmd" &>/dev/null; then
        ok "$cmd  ($(command -v "$cmd"))"
    else
        if [[ "$required" == "optional" ]]; then
            warn "$cmd not found  →  apt: $pkg_apt  dnf: $pkg_dnf"
        else
            fail "$cmd not found" "apt install $pkg_apt  OR  dnf install $pkg_dnf"
        fi
    fi
}

# Probe for a command in extra directories beyond PATH (e.g. ~/.cargo/bin for rustup).
find_cmd() {
    local cmd="$1"
    local extra_dirs=(
        "$HOME/.cargo/bin"
        "/usr/local/cargo/bin"
        "/root/.cargo/bin"
    )
    if command -v "$cmd" &>/dev/null; then
        command -v "$cmd"
        return 0
    fi
    for d in "${extra_dirs[@]}"; do
        if [[ -x "$d/$cmd" ]]; then
            echo "$d/$cmd"
            return 0
        fi
    done
    return 1
}

check_version() {
    local cmd="$1" min="$2"
    local full_path

    if full_path=$(find_cmd "$cmd" 2>/dev/null); then
        # Extract version — use explicit /usr/bin/head to avoid name collision
        local ver
        # || true prevents set -e from triggering if grep finds no match
        ver=$("$full_path" --version 2>&1 | /usr/bin/head -1 \
              | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | /usr/bin/head -1 || true)
        if [[ -n "$ver" ]]; then
            ok "$cmd $ver  ($full_path)"
        else
            ok "$cmd (version unknown)  ($full_path)"
        fi
    else
        fail "$cmd not found" "required >= $min — install via rustup: https://rustup.rs"
    fi
}

# ---------------------------------------------------------------------------
section "Core build tools"
check git     git   git
check make    make  make
check curl    curl  curl
check jq      jq    jq

section "Rust toolchain"
check_version rustc "1.75"
check_version cargo "1.75"
check rustfmt  rustfmt  rustfmt  optional
check clippy   ""       ""       optional

# ---------------------------------------------------------------------------
if $CHECK_ISO; then
    section "ISO build tools"
    check debootstrap   debootstrap    debootstrap
    check xorriso       xorriso        xorriso
    check mksquashfs    squashfs-tools squashfs-tools
    check unsquashfs    squashfs-tools squashfs-tools
    check grub-mkrescue grub-common    grub-common
    check mtools        mtools         mtools
    check update-grub   grub2-common   grub2-tools  optional
    check grub-mkconfig grub2-common   grub2-tools  optional

    # GRUB boot-platform module directories — needed for hybrid ISO
    if [[ -d /usr/lib/grub/i386-pc ]]; then
        ok "grub/i386-pc modules  (/usr/lib/grub/i386-pc — legacy BIOS boot)"
    else
        warn "grub/i386-pc modules not found  →  apt: grub-pc-bin  dnf: grub2-pc  (required for legacy BIOS boot)"
    fi
    if [[ -d /usr/lib/grub/x86_64-efi ]]; then
        ok "grub/x86_64-efi modules  (/usr/lib/grub/x86_64-efi — UEFI boot)"
    else
        warn "grub/x86_64-efi modules not found  →  apt: grub-efi-amd64-bin  dnf: grub2-efi-x64  (required for UEFI boot)"
    fi
fi

# ---------------------------------------------------------------------------
if $CHECK_KERNEL; then
    section "Kernel build tools"
    check gcc     gcc          gcc
    check bison   bison        bison
    check flex    flex         flex
    check bc      bc           bc
    check pahole  dwarves      dwarves
    check xz      xz-utils     xz
    check openssl libssl-dev   openssl-devel  optional
fi

# ---------------------------------------------------------------------------
section "Optional / recommended"
check shellcheck shellcheck  ShellCheck  optional
check qemu-img   qemu-utils  qemu-img    optional
check docker     docker.io   docker-ce   optional

# ---------------------------------------------------------------------------
echo ""
TOTAL=$((PASS + FAIL + WARN))
echo "  Passed:   $PASS / $TOTAL"
[[ $WARN -eq 0 ]] || echo -e "  Warnings: \033[1;33m$WARN\033[0m  (optional — build will still work)"
[[ $FAIL -eq 0 ]] || echo -e "  Missing:  \033[1;31m$FAIL required tool(s)\033[0m"
echo ""

if [[ $FAIL -gt 0 ]]; then
    echo "  ── Install missing tools ──────────────────────────────────"
    echo ""
    echo "  Rust (required for core, cxpkg, installer):"
    echo "    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    echo "    source \"\$HOME/.cargo/env\""
    echo ""
    echo "  Debian / Ubuntu:"
    echo "    sudo apt install git make curl jq build-essential \\"
    echo "        debootstrap xorriso squashfs-tools \\"
    echo "        grub-pc-bin grub-efi-amd64-bin mtools \\"
    echo "        gcc bison flex bc dwarves pahole xz-utils \\"
    echo "        libssl-dev libelf-dev"
    echo ""
    echo "  Fedora / RHEL:"
    echo "    sudo dnf install git make curl jq gcc bison flex bc \\"
    echo "        dwarves pahole xz openssl-devel elfutils-libelf-devel \\"
    echo "        xorriso squashfs-tools \\"
    echo "        grub2-tools grub2-pc grub2-efi-x64 mtools"
    echo ""
    exit 1
fi

echo -e "  \033[1;32mAll required tools are present. Ready to build.\033[0m"
echo ""
exit 0
