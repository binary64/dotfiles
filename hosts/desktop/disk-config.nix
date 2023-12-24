{ disko.devices = {
  disk = {
    my-disk = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "1MiB";
            end = "128MiB";
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
            start = "128MiB";
            end = "100%";
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
