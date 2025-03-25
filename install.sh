#!/bin/bash
set -xeuo pipefail

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount hosts/desktop/disko.nix
sleep 3

sudo mkdir -p /mnt/etc/nixos
sudo cp -r . /mnt/etc/nixos/

sudo nixos-generate-config --root /mnt

sudo nixos-install --no-root-passwd --root /mnt

sudo umount -Rl /mnt
sudo zpool export -a
sudo reboot
