#!/bin bash
set -xeuo pipefail

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /etc/nixos/hosts/desktop/disko.nix

nixos-install --show-trace --no-root-passwd --root /mnt

umount -Rl /mnt
zpool export -a
swapoff -a
reboot now
