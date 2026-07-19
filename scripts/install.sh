#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib.sh"

trap 'die "Installation interrupted."' INT TERM

banner
check_system
read -rp "Proceed with installation? [Y/n] " ans
[[ "$ans" =~ ^([Nn])$ ]] && exit 0
backup
update_system
install_official
install_aur
deploy
refresh
finish
