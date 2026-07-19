#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$HOME/.local/share/cumulus/logs"
BACKUP_DIR="$HOME/.local/share/cumulus/backups"
mkdir -p "$LOG_DIR" "$BACKUP_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%F_%H-%M-%S).log"

RED="\033[31m";GRN="\033[32m";YEL="\033[33m";BLU="\033[34m";RST="\033[0m"
msg(){ printf "%b%s%b\n" "$2" "$1" "$RST"|tee -a "$LOG_FILE"; }
info(){ msg "[INFO] $1" "$BLU"; }
ok(){ msg "[ OK ] $1" "$GRN"; }
warn(){ msg "[WARN] $1" "$YEL"; }
die(){ msg "[FAIL] $1" "$RED"; exit 1; }

banner(){ cat <<EOF
========================================
        CUMULUS INSTALLER
  A brisk and frugal Hyprland rice
========================================
EOF
}

require(){ command -v "$1" >/dev/null || die "$1 not found."; }
check_system(){
 [[ -f /etc/arch-release ]] || die "Arch Linux required."
 require sudo; require git; require rsync; require pacman
 sudo -v || die "sudo failed."
 [[ -d "$ROOT_DIR/home" ]] || die "home/ missing."
 [[ -f "$ROOT_DIR/packages/official.txt" ]] || die "packages/official.txt missing."
 [[ -f "$ROOT_DIR/packages/aur.txt" ]] || die "packages/aur.txt missing."
}

backup(){
 ts=$(date +%F_%H-%M-%S)
 dest="$BACKUP_DIR/$ts"
 mkdir -p "$dest"
 [[ -d "$HOME/.config" ]] && rsync -a "$HOME/.config/" "$dest/config/"
 ok "Backup saved to $dest"
}

update_system(){ sudo pacman -Syu --noconfirm; }

install_official(){
 mapfile -t pkgs < <(grep -Ev '^(#|$)' "$ROOT_DIR/packages/official.txt")
 ((${#pkgs[@]})) && sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

ensure_yay(){
 command -v yay >/dev/null && return
 info "Installing yay..."
 sudo pacman -S --needed --noconfirm base-devel git
 tmp=$(mktemp -d)
 git clone https://aur.archlinux.org/yay.git "$tmp/yay"
 (cd "$tmp/yay" && makepkg -si --noconfirm)
 rm -rf "$tmp"
}

install_aur(){
 ensure_yay
 mapfile -t pkgs < <(grep -Ev '^(#|$)' "$ROOT_DIR/packages/aur.txt")
 ((${#pkgs[@]})) && yay -S --needed --noconfirm "${pkgs[@]}"
}

deploy(){
 rsync -a --exclude=".git" --exclude=".gitkeep" "$ROOT_DIR/home/" "$HOME/"
 ok "Configs deployed."
}

refresh(){ fc-cache -f || true; }

finish(){
 ok "Installation complete."
 echo "Log: $LOG_FILE"
}
