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
set -euo pipefail
MACHINE="$1"

# Format disk
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --yes-wipe-all-disks "hosts/$MACHINE/disko.nix"
sleep 3

# Prepare filesystem
mkdir -p /mnt/etc/nixos
cp -r . /mnt/etc/nixos/
cp "./hosts/${MACHINE}/configuration.nix" /mnt/etc/nixos/

# Install
nixos-generate-config --root /mnt
cp -f /mnt/etc/nixos/hardware-configuration.nix "/mnt/etc/nixos/hosts/${MACHINE}/"
sed -i 's/^\([[:space:]]*nixpkgs\.hostPlatform = lib\.mkDefault "x86_64-linux";\)/\#\1/' "/mnt/etc/nixos/hosts/${MACHINE}/hardware-configuration.nix"
nixos-install --no-root-passwd --root /mnt

# Cleanup
umount -Rl /mnt
zpool export -a
reboot
' _ "$MACHINE"  # Passing $MACHINE as argument
