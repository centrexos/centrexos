# CentrexOS — Container Image
#
# Security model
# ──────────────
# Root access is PROHIBITED for the default container user. The container
# entrypoint starts centrex-core as root (providing a privileged Unix-socket
# API), then drops all interactive/command execution to the 'centrex' user
# (uid 1000). Any operation that needs root must go through the core API:
#
#   docker run centrexos centrex-core --api-call '{"cmd":"pkg-install","packages":["curl"]}'
#
# Recommended run flags:
#   --security-opt no-new-privileges:true
#   --cap-drop ALL
#   --cap-add  NET_ADMIN   (only if network configuration is required)
#
# Build:
#   docker build --build-arg VERSION=0.3.0 -t centrexos:0.3.0 .
#
# Run (interactive shell as centrex user):
#   docker run -it centrexos:0.3.0
#
# Run (API call — requires daemon):
#   docker run centrexos:0.3.0 centrex-core --api-call '{"cmd":"status"}'

ARG VERSION=0.1.0

FROM debian:stable-slim

ARG VERSION
LABEL org.opencontainers.image.title="CentrexOS"
LABEL org.opencontainers.image.description="CentrexOS container image — privileged ops via core API"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/centrexos/centrexos"

# Install minimal runtime deps and gosu (correct privilege-dropping for PID 1)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        bash \
        coreutils \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# Create the non-root centrex user/group (uid/gid 1000)
RUN groupadd -g 1000 centrex && \
    useradd -m -u 1000 -g centrex -s /bin/bash -d /home/centrex centrex

# Install CentrexOS binaries
COPY --chmod=755 centrex-core  /usr/local/bin/centrex-core
COPY --chmod=755 cxpkg         /usr/local/bin/cxpkg
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

# Runtime directories — /run/centrex holds the API socket (root:centrex, 750)
RUN mkdir -p /run/centrex /etc/cxpkg /var/cache/cxpkg \
             /var/lib/cxpkg /opt/centrex_store && \
    chown root:centrex /run/centrex && \
    chmod 750          /run/centrex

# Package manager and OS identity config
COPY cxpkg.config.toml /etc/cxpkg/config.toml
COPY os-release        /etc/os-release

# Persistent data volumes
VOLUME ["/var/lib/cxpkg", "/opt/centrex_store"]

# Health: verify the API daemon is reachable
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
    CMD centrex-core --api-call '{"cmd":"status"}' || exit 1

# Entrypoint runs as root to start daemon, then drops to centrex
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
