#!/bin/env bash

set -euo pipefail

# Check for ability to call sudo (for root)
if ! command -v sudo &>/dev/null; then
	echo "This script requires sudo to be installed."
	exit 1
fi

# Check for internet connection
if ! ping -c 1 1.1.1.1; then
	echo "No internet connection found."
	exit 1
fi

# Check for nix
if ! command -v nix-env &>/dev/null; then
	echo "Nix not found. Please install nix before running this script."
	exit 1
fi

# Check for zfs
if ! command -v zpool &>/dev/null; then
	echo "ZFS not found. Please install zfs before running this script."
	exit 1
fi

echo "Partitioning disk with disko.."
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ~/dotfiles/hosts/desktop/disk-config.nix

echo "Installing OS.."
sudo nixos-install --flake ~/dotfiles#desktop --impure --root /mnt --no-root-passwd

exit 0

sleep 2
echo "Rebooting in 5 seconds..."
sleep 1
echo "Rebooting in 4 seconds..."
sleep 1
echo "Rebooting in 3 seconds..."
sleep 1
echo "Rebooting in 2 seconds..."
sleep 1
echo "Rebooting in 1 second..."
sleep 1
reboot
