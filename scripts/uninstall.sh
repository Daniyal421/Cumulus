#!/usr/bin/env bash
set -euo pipefail
echo "Cumulus does not automatically remove your files."
echo "Restore a backup from:"
echo "~/.local/share/cumulus/backups/"
echo
echo "If you wish to remove deployed configs:"
echo "  rm -rf ~/.config/hypr ~/.config/waybar ~/.config/kitty"
