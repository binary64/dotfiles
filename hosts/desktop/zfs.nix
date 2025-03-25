{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "d1a52b06";
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.zfs.devNodes = "/dev/disk/by-partlabel";
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;

  boot.loader.grub.extraPrepareConfig = ''
    mkdir -p /boot/efis
    for i in  /boot/efis/*; do mount $i ; done

    mkdir -p /boot/efi
    mount /boot/efi
  '';

  boot.loader.grub.extraInstallCommands = ''
    ESP_MIRROR=$(${pkgs.coreutils}/bin/mktemp -d)
    ${pkgs.coreutils}/bin/cp -r /boot/efi/EFI $ESP_MIRROR
    for i in /boot/efis/*; do
      ${pkgs.coreutils}/bin/cp -r $ESP_MIRROR/EFI $i
    done
    ${pkgs.coreutils}/bin/rm -rf $ESP_MIRROR
  '';

  boot.loader.grub.devices = [
    "/dev/sda"
  ];

users.users.root.initialPassword = "123";

}
