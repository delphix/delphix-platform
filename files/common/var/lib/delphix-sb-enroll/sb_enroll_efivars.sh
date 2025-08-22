#!/bin/bash
set -euo pipefail

AUTH_DIR="${SB_AUTH_DIR:-/var/delphix/server/sb_keys/}"

log()  { printf '[sb-enroll] %s\n' "$*" >&2; }
die()  { log "ERROR: $*"; exit 1; }

# Return if Secure Boot is enabled.
sb=$(od -An -t u1 /sys/firmware/efi/efivars/SecureBoot-* | awk '{print $NF}')
[[ $sb -eq 1 ]] && exit 0

#
# Run only on AWS when SB_REQUIRE_AWS=1 (default: 1).
# Expand this to support additional clouds
#
require_aws="${SB_REQUIRE_AWS:-1}"
if [[ "$require_aws" = "1" ]]; then
  if [[ -r /sys/class/dmi/id/sys_vendor ]] && \
    grep -qi 'Amazon EC2' /sys/class/dmi/id/sys_vendor; then
    log "AWS detected (via DMI)"
  else
    log "Not AWS; skipping Secure Boot enrollment."
    exit 0
  fi
fi

[[ -d /sys/firmware/efi/efivars ]] || die "Not booted in UEFI mode (/sys/firmware/efi/efivars missing)."

# Ensure efivars is mounted (usually is on Ubuntu)
if ! mountpoint -q /sys/firmware/efi/efivars; then
  log "Mounting efivarfs..."
  sudo mount -t efivarfs efivarfs /sys/firmware/efi/efivars
fi

[[ -d "$AUTH_DIR" ]] || die "Auth directory not found: $AUTH_DIR"

apply_auth() {
  local var="$1"   # db, KEK, PK
  local file="$AUTH_DIR/${var}.auth"

  sudo efi-updatevar -f "$file" "$var"
  log "${var}: update submitted"
}

apply_auth db
apply_auth KEK
apply_auth PK

log "Rebooting..."
init 6

