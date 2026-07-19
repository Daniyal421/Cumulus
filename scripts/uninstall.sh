#!/usr/bin/env bash
#
# ============================================================
# Cumulus Uninstaller
# ============================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib.sh"

RESTORE=false

########################################
# Help
########################################

usage() {

cat <<EOF

Usage:

    ./scripts/uninstall.sh [OPTIONS]

OPTIONS

    --restore
        Restore latest backup after uninstall

    --help
        Show this help

EOF

}

########################################
# Parse Arguments
########################################

while [[ $# -gt 0 ]]; do

    case "$1" in

        --restore)

            RESTORE=true
            ;;

        --help)

            usage
            exit 0
            ;;

        *)

            die "Unknown option: $1"

            ;;

    esac

    shift

done

########################################
# Banner
########################################

banner

confirm "Remove Cumulus?" || exit 0

########################################
# Remove Configurations
########################################

step "Removing configuration"

rm -rf \
"$HOME/.config/hypr" \
"$HOME/.config/hyprlock" \
"$HOME/.config/hypridle" \
"$HOME/.config/waybar" \
"$HOME/.config/kitty" \
"$HOME/.config/fish" \
"$HOME/.config/rofi" \
"$HOME/.config/swaync" \
"$HOME/.config/cava" \
"$HOME/.config/fastfetch" \
"$HOME/.config/ags"

########################################
# Wallpapers
########################################

rm -rf "$HOME/Pictures/Wallpapers"

########################################
# Icons / Themes
########################################

rm -rf "$HOME/.icons"
rm -rf "$HOME/.themes"

########################################
# Optional Restore
########################################

if [[ "$RESTORE" == true ]]; then

    rollback

fi

########################################
# Finish
########################################

cat <<EOF

========================================

Cumulus has been removed.

Your installed packages were NOT removed.

Backups remain in:

$BACKUP_DIR

========================================

EOF
