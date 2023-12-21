#!/bin/env bash

set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Rest of your script...
echo "Running in a compatible shell."

echo "Installing OS.."

# you only need to set this to the disk to want to install to
# IT WILL BE WIPED
lsblk
echo "Specify disk (ex: sda) :"
read -r rootdisk
echo "Specify passphrase (ex: mysecret007) :"
read -r passphrase

# Probably no need to change anything below or
# in the other scripts, there be dragons

# abort if no root disk is set
if [ -z "$rootdisk" ]; then
	echo "please set rootdisk for \$1"
	exit 2
fi

# abort if no passphrase supplied
if [ -z "$passphrase" ]; then
	echo "please set passphrase for \$2"
	exit 2
fi

export DISK_PATH="/dev/${rootdisk}"
export ZFS_POOL="rpool"

# ephemeral datasets
export ZFS_ENCRYPTED="${ZFS_POOL}/encrypted"
export ZFS_LOCAL="${ZFS_ENCRYPTED}/local"
export ZFS_DS_ROOT="${ZFS_LOCAL}/root"
export ZFS_DS_NIX="${ZFS_LOCAL}/nix"

# persistent datasets
export ZFS_SAFE="${ZFS_ENCRYPTED}/safe"
export ZFS_DS_HOME="${ZFS_SAFE}/home"
export ZFS_DS_PERSIST="${ZFS_SAFE}/persist"

export ZFS_BLANK_SNAPSHOT="${ZFS_DS_ROOT}@blank"


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


partprobe "${DISK_PATH}"
echo "Installing to ${DISK_PATH}"

(
	sgdisk --zap-all ${DISK_PATH}
	sgdisk -a1 -n1:0:+100K -t1:EF02 -c 1:${PART_MBR} ${DISK_PATH}
	sgdisk -n2:1M:+1G -t2:EF00 -c 2:${PART_EFI} ${DISK_PATH}
	sgdisk -n3:0:+4G -t3:BE00 -c 3:${PART_BOOT} ${DISK_PATH}
	sgdisk -n4:0:+${SWAPSIZE} -t4:8200 -c 4:${PART_SWAP} ${DISK_PATH}
	SWAPDEVS+=(${DISK_PATH}4)
	sgdisk -n5:0:0 -t5:BF00 -c 5:${PART_ROOT} ${DISK_PATH}

	partprobe ${d}
	sleep 2
) || (
	echo "Disk not empty! Aborting. If you are you sure you wish to nuke the disk, run sgdisk --zap-all \"$DISK_PATH\""
	exit 4
)
echo "Partitioned disk."

# Wait for a label to show up
while [[ ! -e /dev/disk/by-partlabel/${PART_ROOT} ]];
do
	sleep 1;
done
echo "Labels found!"
sleep 1

## format the EFI partition
mkfs.vfat -F 32 -n boot /dev/disk/by-partlabel/efiboot
echo "Formatted vFAT partition."

# temporary keyfile, will be removed (8k, ridiculously large)
dd if=/dev/urandom of=/tmp/keyfile bs=1k count=8

## now we encrypt the second partition
# pick a strong passphrase

echo "Creating the encrypted partition, follow the instructions and use a strong password!"
# formats the partition with luks and adds the temporary keyfile.
echo "YES" | cryptsetup luksFormat /dev/disk/by-partlabel/cryptroot --key-size 512 --hash sha512 --key-file /tmp/keyfile
echo "Encryption setup."

echo "$passphrase" | cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot --key-file /tmp/keyfile
echo "added passphrase"

# mount the cryptdisk at /dev/mapper/nixroot
cryptsetup luksOpen /dev/disk/by-partlabel/cryptroot nixroot -d /tmp/keyfile
echo "Disk mounted."

# remove the temporary keyfile
cryptsetup luksRemoveKey /dev/disk/by-partlabel/cryptroot /tmp/keyfile
rm -f /tmp/keyfile

zpool create        \
	-O atime=on         \
	-O relatime=on      \
	-O compression=lz4  \
	-O snapdir=visible  \
	-O xattr=sa         \
	-o ashift=12        \
	-o altroot=/mnt     \
	rpool               \
	/dev/mapper/nixroot

echo "Creating dataset for root"
zfs create -o canmount=off -o mountpoint=none rpool/root

echo "Creating dataset for nixos"
zfs create -o mountpoint=legacy rpool/root/nixos

echo "Creating dataset for home"
zfs create -o com.sun:auto-snapshot=true -o copies=2 -o mountpoint=legacy rpool/home

echo "Creating dataset for swap"
zfs create \
	-o com.sun:auto-snapshot=false \
	-o sync=always \
	-o logbias=throughput \
	-o primarycache=metadata \
	-o compression=off \
	-b "$(getconf PAGESIZE)" \
	-V 8G \
	rpool/swap

echo "sleeping..."
sleep 3
mkswap -L SWAP /dev/zvol/rpool/swap
swapon /dev/zvol/rpool/swap

# mount the root dataset at /mnt
mount -t zfs rpool/root/nixos /mnt

# mount the home datset at future /home
mkdir -p /mnt/home
mount -t zfs rpool/home /mnt/home

# mount EFI partition at future /boot
mkdir -p /mnt/boot
mount  /dev/disk/by-partlabel/efiboot /mnt/boot

# set boot filesystem
zpool set bootfs=rpool/root/nixos rpool

nixos-generate-config --root /mnt

echo "Done!"

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

