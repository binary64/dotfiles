# vim: ts=4 sw=4 ai noet si sta fdm=marker
#
# Edit the variables below. Then run this by issuing:
# `bash ./nixos-zfs-setup.sh`
#
# WARNING: this script will clear partition tables of existing disks.
# Make sure that you set the DISK variable correctly. Additionally, it
# is a good idea to clean your disk(s) current partitions first. Use the
# command `wipefs` for this.
#
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

set -ex

DISK=(/dev/sda)
#DISK=(/dev/vda /dev/vdb)

# How to name the partitions. This will be visible in 'gdisk -l /dev/disk' and
# in /dev/disk/by-partlabel.
PART_MBR="bootcode"
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

# Generate a root password with mkpasswd -m SHA-512
ROOTPW='$6$nAffBk9Fxs.0J13A$S4e5cCSd.ITeYAZydUnfwo6eHXiYJuzbp3RPKHf8xtnP25V1Zk0eypKFeg0LXDTnJsfRv5O21TKMavcb3c9qE1'

# Do you want impermanence? In that case set this to 1. Not yes, not hai, 1.
IMPERMANENCE=0

# If IMPERMANENCE is 1, this will be the name of the empty snapshots
EMPTYSNAP="SYSINIT"

# End of settings.

set +x

MAINCFG="/mnt/etc/nixos/configuration.nix"
HWCFG="/mnt/etc/nixos/hardware-configuration.nix"
ZFSCFG="/mnt/etc/nixos/zfs.nix"

if [[ ${#DISK[*]} -eq 1 ]] && [[ -n ${ZFS_BOOT_VDEV} || -n ${ZFS_ROOT_VDEV} ]]
then
	echo "Error: You have only specified one disk. ZFS_BOOT_VDEV and ZFS_ROOT_DEV must be unset or empty." >&2
	false
fi

if [[ -z ${ROOTPW} ]]
then
	echo "Error: Please generate a password hash and put that in this file's ROOTPW variable." >&2
	false
fi

set -x

i=0 SWAPDEVS=()
for d in ${DISK[*]}
do
	sgdisk --zap-all ${d}
	partprobe ${d}
	sleep 2
	
	sgdisk -a1 -n1:0:+100K -t1:EF02 -c 1:${PART_MBR}${i} ${d}
	sgdisk -n2:1M:+4G -t2:EF00 -c 2:${PART_BOOT}${i} ${d}
	sgdisk -n3:0:+${SWAPSIZE} -t3:8200 -c 3:${PART_SWAP}${i} ${d}
	SWAPDEVS+=(${d}3)
	sgdisk -n4:0:0 -t4:BF00 -c 4:${PART_ROOT}${i} ${d}

	partprobe ${d}
	sleep 2
	mkswap -L ${PART_SWAP}fs${i} /dev/disk/by-partlabel/${PART_SWAP}${i}
	#swapon /dev/disk/by-partlabel/${PART_SWAP}${i}
	(( i++ )) || true
done
unset i d

# Wait for a bit to let udev catch up and generate /dev/disk/by-partlabel.
sleep 3s

# Create the boot pool
zpool create \
	-f \
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
	${ZFS_BOOT} ${ZFS_BOOT_VDEV} /dev/disk/by-partlabel/${PART_BOOT}*

# Create the root pool
zpool create \
	-f \
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
	${ZFS_ROOT} ${ZFS_ROOT_VDEV} /dev/disk/by-partlabel/${PART_ROOT}*

# Create the root dataset
zfs create -o mountpoint=/     ${ZFS_ROOT}/${ZFS_ROOT_VOL}

# Create datasets (subvolumes) in the root dataset
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/home
(( $IMPERMANENCE )) && zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/keep || true
zfs create -o atime=off ${ZFS_ROOT}/${ZFS_ROOT_VOL}/nix
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/root
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/usr
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/var

# Make empty snapshots of impermanent volumes
if (( $IMPERMANENCE ))
then
	for i in "" /usr /var
	do
		zfs snapshot ${ZFS_ROOT}/${ZFS_ROOT_VOL}${i}@${EMPTYSNAP}
	done
fi

for i in ${DISK}; do
 mkfs.vfat -n EFI "${i}"2
done

for i in ${DISK}; do
 mount -t vfat -o fmask=0077,dmask=0077,iocharset=iso8859-1,X-mount.mkdir "${i}"2 "${MNT}"/boot
 break
done

# Make sure we won't trip over zpool.cache later
mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

# Generate and edit configs
nixos-generate-config --root /mnt

sed -i -e "s|./hardware-configuration.nix|& ./zfs.nix|" ${MAINCFG}

if (( $IMPERMANENCE ))
then
	echo '{ config, lib, pkgs, ... }:'
else
	echo '{ config, pkgs, ... }:'
fi | tee -a ${ZFSCFG}

tee -a ${ZFSCFG} <<EOF

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "00000001";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.zfs.devNodes = "/dev/disk/by-partlabel";
EOF

if (( $IMPERMANENCE ))
then
	tee -a ${ZFSCFG} <<EOF
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r ${ZFS_ROOT}/${ZFS_ROOT_VOL}@${EMPTYSNAP}
  '';
EOF
fi

# Remove boot.loader stuff, it's to be added to zfs.nix
sed -i '/boot.loader/d' ${MAINCFG}

# Disable xserver. Comment them without a space after the pound sign so we can
# recognize them when we edit the config later
sed -i -e 's;^  \(services.xserver\);  #\1;' ${MAINCFG}

tee -a ${ZFSCFG} <<-'EOF'
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;

  boot.loader.grub.extraPrepareConfig = ''
    mkdir -p /boot/efi
    mount /boot/efi
  '';

  boot.loader.grub.extraInstallCommands = ''
    ESP_MIRROR=$(mktemp -d)
    cp -r /boot/efi/EFI $ESP_MIRROR
    rm -rf $ESP_MIRROR
  '';

  boot.loader.grub.devices = [
EOF

for d in ${DISK[*]}; do
  printf "    \"${d}\"\n" >>${ZFSCFG}
done

tee -a ${ZFSCFG} <<EOF
  ];

EOF

sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' ${HWCFG}

ADDNR=$(awk '/^  fileSystems."\/" =$/ {print NR+3}' ${HWCFG})
sed -i "${ADDNR}i"' \      neededForBoot = true;' ${HWCFG}

if (( $IMPERMANENCE ))
then
	# Of course we want to keep the config files after the initial
	# reboot. So, create a bind mount from /keep/etc/nixos -> /etc/nixos
	# here, and copy the files and actually mount the bind later
	ADDNR=$(awk '/^  swapDevices =/ {print NR-1}' ${HWCFG})
	TMPFILE=$(mktemp)
	head -n ${ADDNR} ${HWCFG} > ${TMPFILE}

	tee -a ${TMPFILE} <<EOF
  fileSystems."/etc/nixos" =
    { device = "/keep/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
    };

EOF

	ADDNR=$(awk '/^  swapDevices =/ {print NR}' ${HWCFG})
	tail -n +${ADDNR} ${HWCFG} >> ${TMPFILE}
	cat ${TMPFILE} > ${HWCFG}
	rm -f ${TMPFILE}
	unset ADDNR TMPFILE
fi

tee -a ${ZFSCFG} <<EOF
users.users.root.initialHashedPassword = "${ROOTPW}";

}
EOF

if (( $IMPERMANENCE ))
then
	# This is where we copy the config files and mount the bind
	install -d -m 0755 /mnt/keep/etc
	cp -a /mnt/etc/nixos /mnt/keep/etc/
	mount -o bind /mnt/keep/etc/nixos /mnt/etc/nixos
fi

set +x

exit 0
nixos-install -v --show-trace --no-root-passwd --root /mnt
#exit 0
umount -Rl /mnt
zpool export -a
swapoff -a
reboot now
