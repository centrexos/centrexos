#!/usr/bin/env bash
# CentrexOS container image build pipeline
#
# Produces a Docker image for container deployments.
# Root is NOT required — this uses `docker build`.
#
# Stages:
#   1. Preflight    — verify tools and pre-built artifacts
#   2. Staging      — copy binaries + configs into a Docker build context
#   3. Build        — docker build → image tagged centrexos:<VERSION>
#   4. Export       — docker save → releases/centrexos-<VERSION>-container.tar.gz
#
# Usage:
#   ./build/build-container.sh
#   VERSION=0.3.0 ./build/build-container.sh
#
# Variables:
#   VERSION   Image version tag          (default: 0.1.0)
#   ARCH      Target arch label          (default: amd64)
#   WORK_DIR  Scratch directory          (default: /tmp/centrexos-container-build)
#   OUTPUT_DIR Release output directory  (default: ./releases)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

VERSION="${VERSION:-0.1.0}"
ARCH="${ARCH:-amd64}"
IMAGE_NAME="centrexos"
IMAGE_TAG="${IMAGE_NAME}:${VERSION}"
WORK_DIR="${WORK_DIR:-/tmp/centrexos-container-build}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/releases}"

# ── helpers ───────────────────────────────────────────────────────────────────
info()  { echo -e "\033[1;34m[container]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[container]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[container]\033[0m $*"; }
error() { echo -e "\033[1;31m[container]\033[0m $*" >&2; exit 1; }
step()  { echo -e "\n\033[1;36m── Stage $1: $2 ──\033[0m"; }

require_cmd()  { command -v "$1" &>/dev/null || error "Missing tool: $1"; }
require_file() { [[ -f "$1" ]] || error "Required file not found: $1"; }

# ── Stage 1: Preflight ────────────────────────────────────────────────────────
step 1 "Preflight"

require_cmd docker

require_file "$ROOT_DIR/core/target/release/centrex-core"
require_file "$ROOT_DIR/cxpkg/target/release/cxpkg"
require_file "$ROOT_DIR/containers/Dockerfile"
require_file "$ROOT_DIR/containers/entrypoint.sh"

# Verify docker daemon is reachable
docker info &>/dev/null || error "Docker daemon not running (or permission denied)"

info "Version: $VERSION"
info "Image:   $IMAGE_TAG"
info "Arch:    $ARCH"

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

# ── Stage 2: Staging ─────────────────────────────────────────────────────────
step 2 "Staging build context"

CONTEXT_DIR="$WORK_DIR/context"
rm -rf "$CONTEXT_DIR"
mkdir -p "$CONTEXT_DIR"

cp "$ROOT_DIR/core/target/release/centrex-core" "$CONTEXT_DIR/"
cp "$ROOT_DIR/cxpkg/target/release/cxpkg"       "$CONTEXT_DIR/"
cp "$ROOT_DIR/containers/entrypoint.sh"          "$CONTEXT_DIR/"
cp "$ROOT_DIR/containers/Dockerfile"             "$CONTEXT_DIR/"

# cxpkg config for container: no flatpak (no user session in containers)
cat > "$CONTEXT_DIR/cxpkg.config.toml" <<'EOF'
[backends]
apt_enabled     = true
dnf_enabled     = false
flatpak_enabled = false
priority        = ["apt"]

[resolver]
allow_downgrades    = false
auto_remove_orphans = false

[cache]
dir          = "/var/cache/cxpkg"
max_age_days = 7
EOF

# os-release for the container variant
cat > "$CONTEXT_DIR/os-release" <<EOF
NAME="CentrexOS"
ID=centrexos
PRETTY_NAME="CentrexOS $VERSION (Container)"
VERSION="$VERSION"
VERSION_ID="$VERSION"
VARIANT="container"
VARIANT_ID="container"
HOME_URL="https://centrexos.org"
SUPPORT_URL="https://github.com/centrexos"
BUG_REPORT_URL="https://github.com/centrexos/centrexos/issues"
EOF

ok "Build context ready: $CONTEXT_DIR"

# ── Stage 3: Build ────────────────────────────────────────────────────────────
step 3 "Build Docker image ($IMAGE_TAG)"

docker build \
    --build-arg VERSION="$VERSION" \
    --tag "$IMAGE_TAG" \
    --tag "${IMAGE_NAME}:latest" \
    --label "build.date=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --label "build.arch=$ARCH" \
    "$CONTEXT_DIR"

ok "Docker image built: $IMAGE_TAG"

# ── Stage 4: Export ───────────────────────────────────────────────────────────
step 4 "Export image to releases/"

ARTIFACT_NAME="centrexos-${VERSION}-container.tar.gz"
ARTIFACT_PATH="$OUTPUT_DIR/$ARTIFACT_NAME"

info "Saving image → $ARTIFACT_PATH"
docker save "$IMAGE_TAG" | gzip > "$ARTIFACT_PATH"

sha256sum "$ARTIFACT_PATH" > "${ARTIFACT_PATH}.sha256"
ok "Checksum: ${ARTIFACT_PATH}.sha256"

# ── Done ─────────────────────────────────────────────────────────────────────
ARTIFACT_SIZE=$(du -sh "$ARTIFACT_PATH" | cut -f1)
echo ""
ok "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "  Container image: $ARTIFACT_PATH  ($ARTIFACT_SIZE)"
ok "  Docker tag:      $IMAGE_TAG"
ok "  Version:         $VERSION   Arch: $ARCH"
ok "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
info "Load and run:"
info "  docker load < $ARTIFACT_PATH"
info "  docker run --security-opt no-new-privileges:true -it $IMAGE_TAG"
echo ""
info "Security note:"
info "  The container runs as 'centrex' (uid 1000) by default."
info "  Root access is prohibited. Privileged ops go through:"
info "  centrex-core --api-call '{\"cmd\":\"pkg-install\",\"packages\":[\"...\"]}'"
