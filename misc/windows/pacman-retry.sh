#!/usr/bin/env bash
# Runs pacman with gentler downloading, for mirrors that rate-limit (HTTP 429):
#  - packages are downloaded PACMAN_PARALLEL at a time (default 1) instead of
#    pacman's default of 5, using a temporary copy of pacman.conf so the system
#    configuration is left alone
#  - a failed run is retried PACMAN_RETRIES times (default 4) with increasing
#    pauses. Downloaded packages stay in pacman's cache and a failed download
#    aborts before anything is installed, so each retry only fetches what is
#    still missing.
#
# Usage: pacman-retry.sh <pacman arguments>
set -uo pipefail

parallel="${PACMAN_PARALLEL:-1}"
retries="${PACMAN_RETRIES:-4}"

conf="$(mktemp)"
trap 'rm -f "$conf"' EXIT
if grep -qE '^[#[:space:]]*ParallelDownloads' /etc/pacman.conf; then
    sed -E "s/^[#[:space:]]*ParallelDownloads.*/ParallelDownloads = $parallel/" /etc/pacman.conf > "$conf"
else
    sed -E "s/^\[options\]/[options]\nParallelDownloads = $parallel/" /etc/pacman.conf > "$conf"
fi

delay=10
for ((attempt = 0; ; attempt++)); do
    pacman --config "$conf" "$@" && exit 0
    status=$?
    if ((attempt >= retries)); then
        echo "pacman failed after $((retries + 1)) attempts" >&2
        exit $status
    fi
    echo "pacman failed (exit $status), retrying in ${delay}s ($((attempt + 1))/$retries)..." >&2
    sleep "$delay"
    delay=$((delay * 2))
done
