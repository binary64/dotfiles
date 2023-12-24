{ pkgs, config, lib, ... }:

{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
    #./disk-config.nix
  ];

  # Use disko
  boot.loader.grub.device = "nodev";
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.devices = [ "/dev/sda" ];


  # Enable the OpenSSH server.
  services.openssh.enable = true;
  # Open the SSH port
  networking.firewall.allowedTCPPorts = [ 22 ];


  ## Local config
  #programs.ssh.startAgent = true;
  #services.openssh.startWhenNeeded = true;

  networking.networkmanager.enable = true;


}
