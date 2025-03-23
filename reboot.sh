#!/bin/bash
set -euo pipefail

umount -Rl /mnt
zpool export -a
swapoff -a
reboot now
