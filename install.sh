#!/bin bash
set -xeuo pipefail

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount hosts/desktop/disko.nix

echo "disko worked"
exit 1

cd hosts/desktop

nixos-install --show-trace --no-root-passwd --root /mnt

umount -Rl /mnt
zpool export -a
swapoff -a
reboot now
