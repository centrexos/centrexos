#!/usr/bin/env bash
# CentrexOS container entrypoint
#
# Security model:
#   Root access is PROHIBITED for the default container user.
#   This script starts centrex-core (privileged API daemon) as root, then drops
#   all further execution to the 'centrex' user (uid 1000). Any operation that
#   requires root must go through the core API socket:
#
#     centrex-core --api-call '{"cmd":"pkg-install","packages":["curl"]}'
#
# Environment variables:
#   CENTREX_DAEMON=1   (default) Start the core API daemon before exec
#   CENTREX_DAEMON=0   Skip daemon start (daemon-less CI / rootless mode)
#   CENTREX_ROOT=1     Stay as root — for privileged debugging ONLY
set -e

SOCKET_PATH="/run/centrex/core.sock"

# Ensure the socket directory exists and is accessible to the centrex group
mkdir -p /run/centrex
chown root:centrex /run/centrex 2>/dev/null || true
chmod 750          /run/centrex 2>/dev/null || true

# ── Start privileged core daemon ──────────────────────────────────────────────
if [ "${CENTREX_DAEMON:-1}" = "1" ] && [ "$(id -u)" = "0" ]; then
    mkdir -p /var/log
    centrex-core --daemon >> /var/log/centrex-core.log 2>&1 &
    DAEMON_PID=$!

    # Wait for the socket (max 5 s)
    READY=0
    for i in $(seq 1 50); do
        if [ -S "$SOCKET_PATH" ]; then
            READY=1
            break
        fi
        sleep 0.1
    done

    if [ "$READY" = "0" ]; then
        echo "[centrexos] ERROR: Core API daemon did not start (pid=$DAEMON_PID)" >&2
        echo "[centrexos]        Check: /var/log/centrex-core.log"               >&2
        exit 1
    fi

    echo "[centrexos] Core API daemon ready  pid=$DAEMON_PID  socket=$SOCKET_PATH"
fi

# ── Drop to non-root centrex user ────────────────────────────────────────────
if [ "$(id -u)" = "0" ] && [ "${CENTREX_ROOT:-0}" != "1" ]; then
    echo "[centrexos] Dropping privileges → centrex (uid=1000)"
    exec gosu centrex "$@"
fi

exec "$@"
