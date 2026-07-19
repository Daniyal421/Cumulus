#!/usr/bin/env bash
#
# ============================================================
#  Cumulus Installer Library
#  A brisk and frugal Hyprland rice.
#
#  Author: Mohammad Daniyal
#  License: MIT
# ============================================================

set -Eeuo pipefail

########################################
# Globals
########################################

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(realpath "$SCRIPT_DIR/..")"

readonly HOME_DIR="$HOME"

readonly PACKAGE_DIR="$ROOT_DIR/packages"
readonly CONFIG_DIR="$ROOT_DIR/home"

readonly OFFICIAL_PACKAGES="$PACKAGE_DIR/official.txt"
readonly AUR_PACKAGES="$PACKAGE_DIR/aur.txt"

readonly DATA_DIR="$HOME/.local/share/cumulus"
readonly CACHE_DIR="$HOME/.cache/cumulus"

readonly BACKUP_DIR="$DATA_DIR/backups"
readonly LOG_DIR="$DATA_DIR/logs"

readonly LOG_FILE="$LOG_DIR/install-$(date '+%Y-%m-%d_%H-%M-%S').log"

########################################
# Colours
########################################

readonly RESET="\033[0m"

readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[1;33m"
readonly BLUE="\033[0;34m"
readonly MAGENTA="\033[0;35m"
readonly CYAN="\033[0;36m"

readonly BOLD="\033[1m"

########################################
# Create directories
########################################

mkdir -p "$DATA_DIR"
mkdir -p "$CACHE_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

########################################
# Logging
########################################

log() {

    printf "[%s] %s\n" \
        "$(date '+%H:%M:%S')" \
        "$1" >> "$LOG_FILE"

}

print() {

    printf "%b%s%b\n" "$2" "$1" "$RESET"

    log "$1"

}

info() {

    print "[INFO] $1" "$BLUE"

}

success() {

    print "[ OK ] $1" "$GREEN"

}

warn() {

    print "[WARN] $1" "$YELLOW"

}

error() {

    print "[FAIL] $1" "$RED"

}

die() {

    error "$1"

    exit 1

}

########################################
# Banner
########################################

banner() {

cat << "EOF"

   ______                __
  / ____/_  ______ ___  / /_  ______
 / /   / / / / __ `__ \/ / / / / __ \
/ /___/ /_/ / / / / / / / /_/ / /_/ /
\____/\__,_/_/ /_/ /_/_/\__,_/ .___/
                             /_/

A brisk and frugal Hyprland rice.

EOF

}

########################################
# Generic helpers
########################################

pause() {

    read -rp "Press Enter to continue..."

}

confirm() {

    local prompt="${1:-Continue?}"

    read -rp "$prompt [Y/n]: " answer

    case "$answer" in

        [Nn]|[Nn][Oo])

            return 1
            ;;

        *)

            return 0
            ;;

    esac

}

command_exists() {

    command -v "$1" >/dev/null 2>&1

}

require_command() {

    command_exists "$1" || die "Required command '$1' is missing."

}

########################################
# Cleanup
########################################

cleanup() {

    rm -rf "$CACHE_DIR/tmp" 2>/dev/null || true

}

trap cleanup EXIT

########################################
# Internet
########################################

check_internet() {

    info "Checking internet connection..."

    if ping -c 1 archlinux.org >/dev/null 2>&1; then

        success "Internet connection available."

    else

        die "No internet connection."

    fi

}

########################################
# Platform checks
########################################

check_arch() {

    info "Checking operating system..."

    [[ -f /etc/arch-release ]] \
        || die "Cumulus only supports Arch Linux."

    success "Arch Linux detected."

}

check_root() {

    if [[ $EUID -eq 0 ]]; then

        die "Do not run the installer as root."

    fi

}

check_sudo() {

    info "Authenticating with sudo..."

    sudo -v || die "Failed to obtain sudo privileges."

    success "sudo authenticated."

}

check_required_tools() {

    info "Checking required tools..."

    local tools=(
        git
        curl
        rsync
        pacman
        bash
        grep
        sed
        awk
        tee
        chmod
        chsh
    )

    for tool in "${tools[@]}"; do

        require_command "$tool"

    done

    success "Required tools found."

}

########################################
# Repository validation
########################################

validate_repository() {

    info "Validating repository..."

    [[ -d "$CONFIG_DIR" ]] \
        || die "Missing home/ directory."

    [[ -f "$OFFICIAL_PACKAGES" ]] \
        || die "Missing packages/official.txt."

    [[ -f "$AUR_PACKAGES" ]] \
        || die "Missing packages/aur.txt."

    [[ -d "$SCRIPT_DIR" ]] \
        || die "Missing scripts directory."

    success "Repository structure verified."

}

########################################
# Backup Existing Configuration
########################################

backup_configs() {

    info "Creating configuration backup..."

    local timestamp
    timestamp="$(date '+%Y-%m-%d_%H-%M-%S')"

    local destination="$BACKUP_DIR/$timestamp"

    mkdir -p "$destination"

    local configs=(
        hypr
        hyprlock
        hypridle
        waybar
        kitty
        fish
        rofi
        swaync
        gtk-3.0
        gtk-4.0
        cava
        fastfetch
        thunar
        nwg-look
        ags
    )

    for cfg in "${configs[@]}"; do

        if [[ -d "$HOME/.config/$cfg" ]]; then

            info "Backing up $cfg"

            rsync -a \
                "$HOME/.config/$cfg" \
                "$destination/"

        fi

    done

    if [[ -d "$HOME/.local/share" ]]; then

        mkdir -p "$destination/.local"

        rsync -a \
            "$HOME/.local/share/" \
            "$destination/.local/share/" \
            --exclude="Trash"

    fi

    success "Backup created:"
    success "$destination"

}

########################################
# Update System
########################################

update_system() {

    info "Synchronising package databases..."

    sudo pacman -Syy --noconfirm

    info "Updating installed packages..."

    sudo pacman -Syu --noconfirm

    success "System updated."

}

########################################
# Package Helpers
########################################

read_package_file() {

    local file="$1"

    grep -Ev '^\s*#|^\s*$' "$file"

}

package_installed() {

    pacman -Qi "$1" >/dev/null 2>&1

}

########################################
# Install Official Packages
########################################

install_official_packages() {

    info "Installing official packages..."

    mapfile -t packages < <(
        read_package_file "$OFFICIAL_PACKAGES"
    )

    if [[ "${#packages[@]}" -eq 0 ]]; then

        warn "No official packages found."

        return

    fi

    sudo pacman \
        -S \
        --needed \
        --noconfirm \
        "${packages[@]}"

    success "Official packages installed."

}

########################################
# Install yay
########################################

install_yay() {

    if command_exists yay; then

        success "yay already installed."

        return

    fi

    info "Installing yay..."

    sudo pacman \
        -S \
        --needed \
        --noconfirm \
        base-devel \
        git

    mkdir -p "$CACHE_DIR/tmp"

    cd "$CACHE_DIR/tmp"

    git clone \
        https://aur.archlinux.org/yay.git

    cd yay

    makepkg -si --noconfirm

    cd "$ROOT_DIR"

    rm -rf "$CACHE_DIR/tmp"

    command_exists yay \
        || die "Failed to install yay."

    success "yay installed."

}

########################################
# Install AUR Packages
########################################

install_aur_packages() {

    install_yay

    info "Installing AUR packages..."

    mapfile -t aur_packages < <(
        read_package_file "$AUR_PACKAGES"
    )

    if [[ "${#aur_packages[@]}" -eq 0 ]]; then

        warn "No AUR packages found."

        return

    fi

    yay \
        -S \
        --needed \
        --noconfirm \
        "${aur_packages[@]}"

    success "AUR packages installed."

}

########################################
# Verify Critical Packages
########################################

verify_installation() {

    info "Verifying critical packages..."

    local required=(
        hyprland
        kitty
        fish
        waybar
        rofi
    )

    for pkg in "${required[@]}"; do

        package_installed "$pkg" \
            || die "$pkg failed to install."

    done

    success "Package verification passed."

}

########################################
# Install Starship
########################################

install_starship() {

    if command_exists starship; then

        success "Starship already installed."

        return

    fi

    info "Installing Starship..."

    curl -fsSL https://starship.rs/install.sh \
        | sh -s -- -y

    command_exists starship \
        || die "Starship installation failed."

    success "Starship installed."

}

########################################
# Configure Fish
########################################

setup_fish() {

    info "Configuring Fish shell..."

    local fish_path

    fish_path="$(command -v fish)"

    [[ -x "$fish_path" ]] \
        || die "Fish executable not found."

    if ! grep -Fxq "$fish_path" /etc/shells; then

        info "Adding Fish to /etc/shells..."

        echo "$fish_path" \
            | sudo tee -a /etc/shells >/dev/null

    fi

    if [[ "$SHELL" != "$fish_path" ]]; then

        info "Changing default shell..."

        chsh -s "$fish_path"

        success "Fish set as default shell."

    else

        success "Fish is already your default shell."

    fi

}

########################################
# Deploy Configuration
########################################

deploy_configs() {

    info "Deploying configuration..."

    rsync \
        -a \
        --delete \
        --exclude=".git" \
        --exclude=".gitkeep" \
        --exclude=".DS_Store" \
        "$CONFIG_DIR/" \
        "$HOME/"

    success "Configuration deployed."

}

########################################
# Install Wallpapers
########################################

install_wallpapers() {

    local source="$ROOT_DIR/assets/wallpapers"

    [[ -d "$source" ]] || return

    info "Installing wallpapers..."

    mkdir -p "$HOME/Pictures/Wallpapers"

    rsync \
        -a \
        "$source/" \
        "$HOME/Pictures/Wallpapers/"

    success "Wallpapers installed."

}

########################################
# Permissions
########################################

fix_permissions() {

    info "Setting executable permissions..."

    find "$HOME/.local/bin" \
        -type f \
        -exec chmod +x {} \; \
        2>/dev/null || true

    find "$HOME/.config/hypr/scripts" \
        -type f \
        -exec chmod +x {} \; \
        2>/dev/null || true

    success "Permissions fixed."

}

########################################
# Font Cache
########################################

refresh_fonts() {

    info "Refreshing font cache..."

    fc-cache -fv >/dev/null

    success "Font cache refreshed."

}

########################################
# GTK Cache
########################################

refresh_icons() {

    gtk-update-icon-cache \
        ~/.icons/* \
        >/dev/null 2>&1 || true

}

########################################
# Fish Plugins
########################################

setup_fish_plugins() {

    if ! command_exists fisher; then

        info "Installing Fisher..."

        fish -c \
        "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"

    fi

}

########################################
# Post Installation
########################################

post_install() {

    info "Running post-install tasks..."

    refresh_fonts

    refresh_icons

    fix_permissions

    success "Post-install tasks complete."

}

########################################
# Finish
########################################

finish() {

cat <<EOF

========================================

 Cumulus has been installed successfully.

 Backup Location:
   $BACKUP_DIR

 Log File:
   $LOG_FILE

========================================

Please reboot or log out before using
Cumulus for the first time.

Enjoy ☁

========================================

EOF

}

########################################
# Rollback
########################################

rollback() {

    warn "Rolling back installation..."

    if [[ -d "$BACKUP_DIR" ]]; then

        latest_backup="$(ls -dt "$BACKUP_DIR"/* 2>/dev/null | head -n1)"

        if [[ -n "$latest_backup" ]]; then

            rsync \
                -a \
                "$latest_backup/" \
                "$HOME/"

            success "Backup restored."

        fi

    fi

}

########################################
# Error Handler
########################################

trap '
echo
error "Installation failed."
rollback
exit 1
' ERR

########################################
# Service Management
########################################

enable_service() {

    local service="$1"

    if systemctl list-unit-files | grep -q "^${service}"; then

        info "Enabling $service..."

        sudo systemctl enable "$service"

        success "$service enabled."

    else

        warn "$service not found."

    fi

}

start_service() {

    local service="$1"

    if systemctl list-unit-files | grep -q "^${service}"; then

        info "Starting $service..."

        sudo systemctl start "$service"

        success "$service started."

    fi

}

enable_user_service() {

    local service="$1"

    if systemctl --user list-unit-files | grep -q "^${service}"; then

        info "Enabling user service $service..."

        systemctl --user enable "$service"

        systemctl --user start "$service"

        success "$service enabled."

    fi

}

########################################
# Enable Required Services
########################################

enable_required_services() {

    info "Enabling required services..."

    enable_service NetworkManager.service
    enable_service bluetooth.service

    success "Required services enabled."

}

########################################
# Session Validation
########################################

verify_session() {

    info "Checking installed desktop..."

    command_exists Hyprland \
        || die "Hyprland was not installed."

    command_exists waybar \
        || die "Waybar was not installed."

    command_exists fish \
        || die "Fish was not installed."

    command_exists kitty \
        || die "Kitty was not installed."

    command_exists rofi \
        || die "Rofi was not installed."

    success "Desktop verified."

}

########################################
# Version Information
########################################

installer_version() {

    echo "Cumulus Installer v1.0.0"

}

########################################
# Debug
########################################

debug() {

    if [[ "${DEBUG:-0}" == "1" ]]; then

        print "[DEBUG] $1" "$MAGENTA"

    fi

}

########################################
# Timing
########################################

SECONDS=0

start_timer() {

    INSTALL_START=$SECONDS

}

stop_timer() {

    local elapsed=$((SECONDS - INSTALL_START))

    success "Installation completed in ${elapsed}s."

}

########################################
# Progress
########################################

step() {

    echo
    print "==> $1" "$CYAN"
    echo

}

########################################
# Temporary Directory
########################################

create_temp() {

    mkdir -p "$CACHE_DIR/tmp"

}

remove_temp() {

    rm -rf "$CACHE_DIR/tmp" 2>/dev/null || true

}

########################################
# Cleanup
########################################

cleanup_install() {

    info "Cleaning temporary files..."

    remove_temp

    success "Cleanup complete."

}

########################################
# Safe Exit
########################################

safe_exit() {

    cleanup_install

    stop_timer

}

########################################
# Failure Handler
########################################

failure_handler() {

    echo

    error "The installer encountered an unexpected error."

    echo

    warn "Attempting rollback..."

    rollback

    echo

    error "Installation aborted."

    echo "See log for details:"
    echo "$LOG_FILE"

    exit 1

}

########################################
# Success Handler
########################################

success_handler() {

    safe_exit

    finish

}

########################################
# Register Traps
########################################

trap failure_handler ERR

trap cleanup_install EXIT

########################################
# Library Initialisation
########################################

init() {

    banner

    start_timer

    create_temp

    debug "Library initialised."

}
