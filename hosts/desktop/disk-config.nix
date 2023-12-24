{ lib, disks ? [ "/dev/sda" ], ... }: {
{ disko.devices = {
  disk = {
    my-disk = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          {
            name = "ESP";
            size = "256MiB";
            flags = [ "esp" ];
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = [ "-F" "32" "-n" "EFI" ];
              mountpoint = "/boot";
            };
          }
          {
            name = "primary";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              keyFile = "/tmp/cryptroot.key";
              extraFormatArgs = [ "--type" "luks1" "--hash" "sha512" ];
              extraOpenArgs = [
                "--allow-discards"
                "--perf-no_read_workqueue"
                "--perf-no_write_workqueue"
              ];
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [ "-L" "nixos" ];
                mountpoint = "/";
              };
            };
          }
        ];
      };
    };
  };
}; }
