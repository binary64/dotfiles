# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/nixos";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
      neededForBoot = true;
    };

  fileSystems."/home" =
    { device = "rpool/nixos/home";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/nix" =
    { device = "rpool/nixos/nix";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/root" =
    { device = "rpool/nixos/root";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/usr" =
    { device = "rpool/nixos/usr";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var" =
    { device = "rpool/nixos/var";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot" =
    { device = "bpool/nixos/boot";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
      neededForBoot = true;
    };

  fileSystems."/boot/efis/efiboot0" =
    { device = "/dev/disk/by-label/EFI";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
      options = [ "fmask=0022" "dmask=0022" ];
      neededForBoot = true;
    };

  fileSystems."/boot/efi" =
    { device = "/boot/efis/efiboot0";
      fsType = "none";
      options = [ "bind" ];
    };

  swapDevices =
    [
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens32.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
