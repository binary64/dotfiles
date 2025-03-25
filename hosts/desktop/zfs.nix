{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "d1a52b06";
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.zfs.devNodes = "/dev/disk/by-partlabel";
  
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  
  # GRUB configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];
  
  boot.loader.grub.extraPrepareConfig = ''
    mkdir -p /boot
    mount /dev/disk/by-label/BOOT /boot
  '';

  boot.loader.grub.extraInstallCommands = ''
    ${pkgs.coreutils}/bin/mkdir -p /boot/EFI
  '';

  # Initial root password
  users.users.root.initialPassword = "123";

  # Ensure the boot partition is mounted early
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "nofail" ];
  };
}