#!/bin bash
set -xeuo pipefail

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --yes-wipe-all-disks hosts/desktop/disko.nix

mkdir -p /mnt/home/etc/nixos
cp -r hosts/desktop/* /mnt/home/etc/nixos

nixos-install --show-trace --no-root-passwd --root /mnt/home

umount -Rl /mnt
zpool export -a
swapoff -a
reboot now
