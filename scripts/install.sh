#!/usr/bin/env bash
#
# ============================================================
# Cumulus Installer
# A brisk and frugal Hyprland rice.
# ============================================================

set -Eeuo pipefail

########################################
# Directories
########################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(realpath "$SCRIPT_DIR/..")"

source "$SCRIPT_DIR/lib.sh"

########################################
# Installer Options
########################################

SKIP_BACKUP=false
SKIP_UPDATE=false
SKIP_AUR=false
SKIP_STARSHIP=false
NON_INTERACTIVE=false
DEBUG=0

########################################
# Usage
########################################

usage() {

cat <<EOF

Cumulus Installer

Usage:

    ./scripts/install.sh [OPTIONS]

OPTIONS

    --help
        Show this help page

    --yes
        Install without confirmation

    --debug
        Enable debug output

    --no-backup
        Skip configuration backup

    --skip-update
        Skip pacman -Syu

    --skip-aur
        Skip AUR packages

    --skip-starship
        Skip Starship installation

EOF

}

########################################
# Parse Arguments
########################################

while [[ $# -gt 0 ]]; do

    case "$1" in

        --help)

            usage
            exit 0
            ;;

        --yes)

            NON_INTERACTIVE=true
            ;;

        --debug)

            DEBUG=1
            export DEBUG
            ;;

        --no-backup)

            SKIP_BACKUP=true
            ;;

        --skip-update)

            SKIP_UPDATE=true
            ;;

        --skip-aur)

            SKIP_AUR=true
            ;;

        --skip-starship)

            SKIP_STARSHIP=true
            ;;

        *)

            die "Unknown option: $1"

            ;;

    esac

    shift

done

########################################
# Initialisation
########################################

init

########################################
# Confirmation
########################################

if [[ "$NON_INTERACTIVE" == false ]]; then

    confirm "Install Cumulus?" || exit 0

fi

########################################
# System Validation
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

if [[ "$SKIP_BACKUP" == false ]]; then

    step "Creating backup"

    backup_configs

fi

########################################
# Update
########################################

if [[ "$SKIP_UPDATE" == false ]]; then

    step "Updating system"

    update_system

fi

########################################
# Official Packages
########################################

step "Installing official packages"

install_official_packages

verify_installation

########################################
# AUR
########################################

if [[ "$SKIP_AUR" == false ]]; then

    step "Installing AUR packages"

    install_aur_packages

fi

########################################
# Starship
########################################

if [[ "$SKIP_STARSHIP" == false ]]; then

    step "Installing Starship"

    install_starship

fi

########################################
# Fish
########################################

step "Configuring Fish"

setup_fish

########################################
# Configuration
########################################

step "Deploying configuration"

deploy_configs

install_wallpapers

########################################
# Services
########################################

step "Enabling services"

enable_required_services

########################################
# Post Installation
########################################

step "Running post-install tasks"

post_install

########################################
# Success
########################################

success_handler

exit 0
