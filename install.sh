#!/bin/bash
set -xeuo pipefail

# --- Dynamically load fzf via nix-shell ---
MACHINE=$(nix-shell -p fzf --run '
  find hosts -name disko.nix | 
  awk -F/ '\''{print $2}'\'' | 
  fzf --height=40% --reverse --prompt="Select machine: "
')

[[ -z "$MACHINE" ]] && { echo "No machine selected. Exiting."; exit 1; }

# --- Confirmation Prompt ---
read -p "WARNING: This will DESTROY ALL DATA on $MACHINE's disk. Continue? (y/N) " confirm
[[ "${confirm,,}" != "y" ]] && { echo "Aborted."; exit 1; }

# --- Run as root ---
sudo bash -c '
set -xeuo pipefail
MACHINE="$1"

# Format disk
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --yes-please-wipe "hosts/$MACHINE/disko.nix"
sleep 3

# Prepare filesystem
mkdir -p /mnt/etc/nixos
cp -r . /mnt/etc/nixos/

# Install
nixos-generate-config --root /mnt
nixos-install --no-root-passwd --root /mnt --flake ".#$MACHINE"

# Cleanup
umount -Rl /mnt
zpool export -a
reboot
' _ "$MACHINE"  # Passing $MACHINE as argument