#!/bin/bash
set -xeuo pipefail

# --- Interactive Machine Selection with fzf ---
MACHINE=$(
  find hosts -name disko.nix | 
  awk -F/ '{print $2}' | 
  fzf --height=40% --reverse --prompt="Select machine: "
)

if [[ -z "$MACHINE" ]]; then
  echo "No machine selected. Exiting."
  exit 1
fi

# --- Verify disko config exists ---
DISKO_CONFIG="hosts/$MACHINE/disko.nix"
if [[ ! -f "$DISKO_CONFIG" ]]; then
  echo "Error: $DISKO_CONFIG not found (but was listed?)"
  exit 1
fi

# --- Disk Wipe Confirmation Prompt ---
read -p "WARNING: This will DESTROY ALL DATA on the target disk. Continue? (y/N) " confirm
if [[ "${confirm,,}" != "y" ]]; then
  echo "Aborted. No changes were made."
  exit 1
fi

# --- Proceed with Installation ---
sudo -i

echo "Running disko on config: ${DISKO_CONFIG}..."
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --yes-wipe-all-disks "$DISKO_CONFIG"
echo "Disko is all done! Waiting a few seconds because idk"
sleep 3

mkdir -p /mnt/etc/nixos
cp -r . /mnt/etc/nixos/

nixos-generate-config --root /mnt

nixos-install --no-root-passwd --root /mnt

sudo umount -Rl /mnt
sudo zpool export -a
sudo reboot
