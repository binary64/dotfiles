#!/bin/env bash

set -euo pipefail

# Check for existence of `sudo` binary
if ! command -v sudo &>/dev/null; then
	echo "sudo not found. Please install sudo before running this script."
	exit 1
fi

# Check that UID is defined and is 0
if [ -z "${UID+x}" ] || [ "$UID" -ne 0 ]; then
	echo "Please run this script as root."
	exit 1
fi

# Check for internet connection
if ! ping -c 1 1.1.1.1 &>/dev/null; then
	echo "No internet connection found."
	exit 1
fi

# Check for nix
if ! command -v nix &>/dev/null; then
	echo "Nix not found. Please install nix before running this script."
	exit 1
fi

# Check for zfs
if ! command -v zpool &>/dev/null; then
	echo "ZFS not found. Please install zfs before running this script."
	exit 1
fi

echo "Partitioning disk with disko.."
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake ~/dotfiles#desktop

echo "Installing OS.."
sudo nixos-install --flake ~/dotfiles#desktop --impure --root /mnt --no-root-passwd

# Ensure /mnt directory exists
if [ ! -d /mnt ]; then
	echo "/mnt directory not found. Something went wrong."
	exit 1
fi

cp -r ~/dotfiles /mnt/etc/nixos
lsblk

echo "DONE! You should now \`reboot\` into your new system."
