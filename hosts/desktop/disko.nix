{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition
            bios_boot = {
              size = "1M";
              type = "EF02";  # BIOS boot partition type
              priority = 0;
            };
            boot = {
              size = "512M";
              type = "EF00";  # EFI System Partition type
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}