{ lib, disks ? [ "/dev/nvme0n1" ], ... }:

{
  disko.devices = {
    disk = {
      root = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" ];
              };
            };
            linux-swap = {
              size = "16G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            windows = {
              size = "1G";
              type = "0700";
              content = {
                type = "filesystem";
                format = "ntfs";
              };
            };
            linux-root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";

        # Pool-level properties:
        options = {
          ashift = "12";
          autotrim = "on";
        };

        # Dataset defaults:
        rootFsOptions = {
          compression = "zstd";
          mountpoint = "none";
          atime = "off";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              recordsize = "128K";
              xattr = "sa";
              acltype = "posixacl";
            };
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              recordsize = "128K";
              xattr = "sa";
              acltype = "posixacl";
              dedup = "off";
            };
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              recordsize = "16K";
              dedup = "off";
              primarycache = "all";
              secondarycache = "all";
              logbias = "throughput";
              sync = "disabled";
            };
          };
        };
      };
    };
  };
}