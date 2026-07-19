#!/usr/bin/env bash
#
# ============================================================
# Cumulus Updater
# ============================================================

set -Eeuo pipefail

########################################
# Directories
########################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(realpath "$SCRIPT_DIR/..")"

source "$SCRIPT_DIR/lib.sh"

########################################
# Help
########################################

usage() {

cat <<EOF

Cumulus Updater

Usage:

    ./scripts/update.sh

This will:

  • Update system packages
  • Update AUR packages
  • Pull latest Cumulus files
  • Deploy updated configuration
  • Refresh font cache
  • Restart desktop components

EOF

}

########################################
# Arguments
########################################

if [[ "${1:-}" == "--help" ]]; then

    usage
    exit 0

fi

########################################
# Initialisation
########################################

init

########################################
# Validation
########################################

step "Checking system"

check_root
check_arch
check_internet
check_sudo
check_required_tools
validate_repository

########################################
# Backup
########################################

step "Creating backup"

backup_configs

########################################
# Git Update
########################################

if command_exists git && [[ -d "$ROOT_DIR/.git" ]]; then

    step "Updating repository"

    git -C "$ROOT_DIR" pull --ff-only

fi

########################################
# Update Packages
########################################

step "Updating system"

update_system

########################################
# Official Packages
########################################

step "Checking official packages"

install_official_packages

########################################
# AUR Packages
########################################

if command_exists yay; then

    step "Updating AUR packages"

    yay -Syu --noconfirm

    install_aur_packages

fi

########################################
# Starship
########################################

if ! command_exists starship; then

    step "Installing Starship"

    install_starship

fi

########################################
# Fish
########################################

step "Checking Fish"

setup_fish

########################################
# Deploy
########################################

step "Updating configuration"

deploy_configs

install_wallpapers

########################################
# Services
########################################

step "Checking services"

enable_required_services

########################################
# Restart Components
########################################

step "Restarting desktop"

pkill waybar 2>/dev/null || true
pkill swaync 2>/dev/null || true
pkill hypridle 2>/dev/null || true

waybar >/dev/null 2>&1 &
swaync >/dev/null 2>&1 &
hypridle >/dev/null 2>&1 &

########################################
# Post Install
########################################

post_install

########################################
# Finish
########################################

success_handler

exit 0
