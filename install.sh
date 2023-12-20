#/bin/env bash

set -e

echo "Installing OS.."

# you only need to set this to the disk to want to install to
# IT WILL BE WIPED
rootdisk="${1}";
passphrase="${2}"

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

# absolute location for this script (directory the files are in)
export scriptlocation=$(dirname $(readlink -f $0))

partprobe "${rootdisk}"
echo "Installing to ${rootdisk}"

# we will create a new GPT table
#
# o:         create new GPT table
#         y: confirm creation
#
# with the new partition table,
# we now create the EFI partition
#
# n:         create new partion
#         1: partition number
#      2048: start position
#     +300M: make it 300MB big
#      ef00: set an EFI partition type
#
# With the EFI partition, we
# use the rest of the disk for LUKS
#
# n:         create new partition
#         2: partition number
#   <empty>: start partition right after first
#   <empty>: use all remaining space
#      8300: set generic linux partition type
#
# We only need to set the partition labels 
#
# c:         change partition label
#         1: partition to label
#   efiboot: name of the partition
# c:         change partition label
#         2: partition to label
# cryptroot: name of the partition
# 
# w:	     write changes and quit
#         y: confirm write

gdisk ${rootdisk} >/dev/null <<end_of_commands
o
y
n
1
2048
+300M
ef00
n
2
8300
c
1
efiboot
c
2
cryptroot
w
y
end_of_commands
echo "Partitioned disk."

# check for the newly created partitions
# this sometimes gives unrelated errors
# so we change it to  `partprobe || true`
partprobe "${rootdisk}" >/dev/null || true

# wait for label to show up
while [[ ! -e /dev/disk/by-partlabel/efiboot ]];
do
	sleep 2;
done
# wait for label to show up
while [[ ! -e /dev/disk/by-partlabel/cryptroot ]];
do
	sleep 2;
done
echo "Label found!"

# check if both labels exist
ls /dev/disk/by-partlabel/efiboot   >/dev/null
ls /dev/disk/by-partlabel/cryptroot >/dev/null

## format the EFI partition
mkfs.vfat /dev/disk/by-partlabel/efiboot
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

cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot  -d /tmp/keyfile --new-keyfile-size="${keysize}" "${keyfile}"
echo "added keyfile"

# mount the cryptdisk at /dev/mapper/nixroot
cryptsetup luksOpen /dev/disk/by-partlabel/cryptroot nixroot -d /tmp/keyfile
echo "Disk mounted."

# remove the temporary keyfile
cryptsetup luksRemoveKey /dev/disk/by-partlabel/cryptroot /tmp/keyfile
rm -f /tmp/keyfile

## the actual zpool create is below
#
# zpool create        \
# -O atime=on         \ #
# -O relatime=on      \ # only write access time (requires atime, see man zfs)
# -O compression=lz4  \ # compress all the things! (man zfs)
# -O snapdir=visible  \ # ever so sligthly easier snap management (man zfs)
# -O xattr=sa         \ # selinux file permissions (man zfs)
# -o ashift=12        \ # 4k blocks (man zpool)
# -o altroot=/mnt     \ # temp mount during install (man zpool)
# rpool               \ # new name of the pool
# /dev/mapper/nixroot   # devices used in the pool (in my case one, so no mirror or raid)

zpool create        \
-O atime=on         \
-O relatime=on      \
-O compression=lz4  \
-O snapdir=visible  \
-O xattr=sa         \
-o ashift=12        \
-o altroot=/mnt     \
rpool               \
/dev/mapper/nixroot \


# dataset for / (root)
zfs create -o mountpoint=none rpool/root
echo created root dataset
zfs create -o mountpoint=legacy rpool/root/nixos

# dataset for home, make copies of all files against corruption
zfs create -o copies=2 -o mountpoint=legacy rpool/home

# dataset for swap
zfs create -o compression=off -V 8G rpool/swap
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

# enable auto snapshots for home dataset
# defaults to keeping:
# - 4 frequent snapshots (1 per 15m)
# - 24 hourly snapshots
# - 7 daily snapshots 
# - 4 weekly snapshots 
# - 12 monthly snapshots
zfs set com.sun:auto-snapshot=true rpool/home

nixos-generate-config --root /mnt

if [[ "$keyfile" != "NONE" ]];
then 
  # add lukskeyfile.nix
  cp "${scriptlocation}/lukskeyfile.nix" /mnt/etc/nixos/

  # replace `/path/to/device` with actual keyfile
  echo "path to device"
  blkdevice="$(basename "$(ls -l /dev/disk/by-partlabel/cryptroot | awk '{print $11}')")";
  device="$(ls -l /dev/disk/by-partuuid/ | grep "$blkdevice" | awk '{print $9}')"
  sed -i'' -e "s!/path/to/device!${device}!" /mnt/etc/nixos/lukskeyfile.nix;
  
  # replace `/path/to/keyfile` with actual keyfile
  sed -i '' -e "s!/path/to/keyfile!${keyfile}!" /mnt/etc/nixos/lukskeyfile.nix;

  # replace placeholder keysize with actual keysize
  sed -i '' -e "s!keyfile_size_here!${keysize}!"             /mnt/etc/nixos/lukskeyfile.nix;
  
  # add ./lukskeyfile.nix to the imports of configuration.nix
  sed -i '' -e "s!\(./hardware-configuration.nix\)!\1\n      ./lukskeyfile.nix!" /mnt/etc/nixos/configuration.nix
fi

# add the zfs.nix
cp "${scriptlocation}/zfs.nix" /mnt/etc/nixos/

# generate and insert a unique hostid
hostid="$(head -c4 /dev/urandom | od -A none -t x4)"
sed -i '' -e "s!cafebabe!${hostid}!"                                   /mnt/etc/nixos/zfs.nix

# add ./zfs.nix to the imports of configuration.nix
sed -i '' -e "s!\(./hardware-configuration.nix\)!\1\n      ./zfs.nix!" /mnt/etc/nixos/configuration.nix

echo "Done!"
echo "Please check if if everything looks allright in all the files in /mnt/etc/nixos/"


