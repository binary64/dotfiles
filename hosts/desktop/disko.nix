{ lib, disks ? [ "/dev/nvme0n1" ], ... }:

{
  disko.devices = {
    disk = {
      nvme0n1 = {
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
              size = "16G";  # Adjust based on your RAM
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            windows = {
              size = "1G";
              type = "0700";  # Microsoft Basic Data
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
        rootFsOptions = {
          compression = "zstd";
          mountpoint = "none";
          atime = "off";
          ashift = "12";
          autotrim = "on";  # Enable TRIM for SSDs
          "com.sun:auto-snapshot" = "false"; # No need for /nix snapshots
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
              dedup = "off";         # Dedup hurts performance
            };
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              recordsize = "16K";    # Matches typical NAR file chunks
              dedup = "off";         # Dedup hurts performance
              primarycache = "all";  # Cache both metadata and data
              secondarycache = "all"; 
              logbias = "throughput"; # Prioritize speed over sync writes
              sync = "disabled";      # Safe for rebuilds (atomic by design)
            };
          };
        };
      };
    };
  };
}