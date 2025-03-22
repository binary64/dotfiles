# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [];

  boot.initrd.availableKernelModules = ["ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" =
    { device = "rpool/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/nixos/home";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/root" =
    { device = "rpool/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/usr" =
    { device = "rpool/nixos/usr";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "rpool/nixos/var";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "rpool/nixos/boot";
      fsType = "zfs";
    };

  fileSystems."/boot/efis/efiboot0" =
    { device = "/dev/disk/by-uuid/0ABE-3E53";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/boot/efi" =
    { device = "/boot/efis/efiboot0";
      fsType = "none";
      options = [ "bind" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens33.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
