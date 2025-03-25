#!/bin/bash
set -xeuo pipefail

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount hosts/desktop/disko.nix
sleep 3

sudo mkdir -p /mnt/etc/nixos
sudo cp hosts/desktop/configuration.nix /mnt/etc/nixos/

sudo nixos-generate-config --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
