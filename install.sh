#/bin/env bash

set -e

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
# check if both labels exist
ls /dev/disk/by-partlabel/efiboot   >/dev/null
ls /dev/disk/by-partlabel/cryptroot >/dev/null

## format the EFI partition
mkfs.vfat /dev/disk/by-partlabel/efiboot



bash formatluks.sh
bash formatzfs.sh

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


