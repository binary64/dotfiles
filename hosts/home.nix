{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  #imports = [ ./tmux.nix ];

  time.timeZone = mkDefault "Europe/London";
  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  console.keyMap = "uk";
  hardware.opengl.enable = true;
  environment.shells = with pkgs; [bashInteractive fish];
  environment.systemPackages = with pkgs; [
    cachix
  ];
  programs = {
    #   neovim = {
    #     enable = true;
    #   };
      hyprland = {
        enable = true;
      };
  };
  #environment.systemPackages = with pkgs; [
  #  nodePackages.pnpm
  #];

  #programs.steam.enable = true;

  # set a super secure initial root password
  users.users.root.initialHashedPassword = "$6$nAffBk9Fxs.0J13A$S4e5cCSd.ITeYAZydUnfwo6eHXiYJuzbp3RPKHf8xtnP25V1Zk0eypKFeg0LXDTnJsfRv5O21TKMavcb3c9qE1"

  # better for steam proton games
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "$(head -c 8 /etc/machine-id)";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
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
    ESP_MIRROR=$(mktemp -d)
    cp -r /boot/efi/EFI $ESP_MIRROR
    for i in /boot/efis/*; do
      cp -r $ESP_MIRROR/EFI $i
    done
    rm -rf $ESP_MIRROR
  '';

  boot.loader.grub.devices = [
    /dev/sda
  ];
}
