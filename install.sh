#!/bin/env bash

###############################################################################
#    nixos-zfs-setup.sh: a bash script that sets up zfs disks for NixOS.      #
#      Copyright (C) 2022  Mark (voidzero) van Dijk, The Netherlands.         #
#                                                                             #
#    This program is free software: you can redistribute it and/or modify     #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    This program is distributed in the hope that it will be useful,          #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.   #
###############################################################################

set -euo pipefail

# Check for existence of `sudo` binary
if ! command -v sudo &>/dev/null; then
	echo "sudo not found. Please install sudo before running this script."
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

DISK=(/dev/sda)
echo "Partitioning zfs onto ${DISK} using sgdisk.."

# How to name the partitions. This will be visible in 'gdisk -l /dev/disk' and
# in /dev/disk/by-partlabel.
PART_MBR="bootcode"
PART_EFI="efiboot"
PART_BOOT="bpool"
PART_SWAP="swap"
PART_ROOT="rpool"

# How much swap per disk?
SWAPSIZE=2G

# The type of virtual device for boot and root. If kept empty, the disks will
# be joined (two 1T disks will give you ~2TB of data). Other valid options are
# mirror, raidz types and draid types. You will have to manually add other
# devices like spares, intent log devices, cache and so on. Here we're just
# setting this up for installation after all.
#ZFS_BOOT_VDEV="mirror"
#ZFS_ROOT_VDEV="mirror"

# How to name the boot pool and root pool.
ZFS_BOOT="bpool"
ZFS_ROOT="rpool"

# How to name the root volume in which nixos will be installed.
# If ZFS_ROOT is set to "rpool" and ZFS_ROOT_VOL is set to "nixos",
# nixos will be installed in rpool/nixos, with a few extra subvolumes
# (datasets).
ZFS_ROOT_VOL="nixos"

i=0 SWAPDEVS=()
for d in ${DISK[*]}; do
	sgdisk --zap-all "${d}"
	sgdisk -a1 -n1:0:+100K -t1:EF02 -c 1:${PART_MBR}${i} "${d}"
	sgdisk -n2:1M:+1G -t2:EF00 -c 2:${PART_EFI}${i} "${d}"
	sgdisk -n3:0:+4G -t3:BE00 -c 3:${PART_BOOT}${i} "${d}"
	sgdisk -n4:0:+${SWAPSIZE} -t4:8200 -c 4:${PART_SWAP}${i} "${d}"
	SWAPDEVS+=(${d}4)
	sgdisk -n5:0:0 -t5:BF00 -c 5:${PART_ROOT}${i} "${d}"

	partprobe "${d}"
	sleep 2
	mkswap -L ${PART_SWAP}fs${i} /dev/disk/by-partlabel/${PART_SWAP}${i}
	#swapon /dev/disk/by-partlabel/${PART_SWAP}${i}
	((i++)) || true
done
unset i d

# Wait for a bit to let udev catch up and generate /dev/disk/by-partlabel.
sleep 6s

# Create the boot pool
zpool create \
	-o compatibility=grub2 \
	-o ashift=12 \
	-o autotrim=on \
	-O acltype=posixacl \
	-O compression=lz4 \
	-O devices=off \
	-O normalization=formD \
	-O relatime=on \
	-O xattr=sa \
	-O mountpoint=none \
	-O checksum=sha256 \
	-R /mnt \
	${ZFS_BOOT} /dev/disk/by-partlabel/${PART_BOOT}*

# Create the root pool
zpool create \
	-o ashift=12 \
	-o autotrim=on \
	-O acltype=posixacl \
	-O compression=zstd \
	-O dnodesize=auto -O normalization=formD \
	-O relatime=on \
	-O xattr=sa \
	-O mountpoint=none \
	-O checksum=edonr \
	-R /mnt \
	${ZFS_ROOT} /dev/disk/by-partlabel/${PART_ROOT}*

# Create the boot dataset
zfs create ${ZFS_BOOT}/${ZFS_ROOT_VOL}

# Create the root dataset
zfs create -o mountpoint=/ ${ZFS_ROOT}/${ZFS_ROOT_VOL}

# Create datasets (subvolumes) in the root dataset
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/home
zfs create -o atime=off ${ZFS_ROOT}/${ZFS_ROOT_VOL}/nix
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/root
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/usr
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/var

# Create datasets (subvolumes) in the boot dataset
# This comes last because boot order matters
zfs create -o mountpoint=/boot ${ZFS_BOOT}/${ZFS_ROOT_VOL}/boot

# Create, mount and populate the efi partitions
i=0
for d in ${DISK[*]}; do
	mkfs.vfat -n EFI /dev/disk/by-partlabel/${PART_EFI}${i}
	mkdir -p /mnt/boot/efis/${PART_EFI}${i}
	mount -t vfat /dev/disk/by-partlabel/${PART_EFI}${i} /mnt/boot/efis/${PART_EFI}${i}
	((i++)) || true
done
unset i d

# Mount the first drive's efi partition to /mnt/boot/efi
mkdir /mnt/boot/efi
mount -t vfat /dev/disk/by-partlabel/${PART_EFI}0 /mnt/boot/efi

# Make sure we won't trip over zpool.cache later
mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

echo "Installing OS.."
nixos-generate-config --root /mnt

# Ensure /mnt directory exists
if [ ! -d /mnt ]; then
	echo "/mnt directory not found. Something went wrong."
	exit 1
fi

cp -r ./* /mnt/etc/nixos
lsblk
ls -al /mnt
