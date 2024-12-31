{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ../home.nix
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot = {
    loader = {
      grub = {
        devices = ["/dev/sda"];
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };

  # Enable the OpenSSH server.
  services.openssh.enable = true;
  # Open the SSH port
  networking.firewall.allowedTCPPorts = [22];

  ## Local config
  #programs.ssh.startAgent = true;
  #services.openssh.startWhenNeeded = true;

  networking.networkmanager.enable = true;
}
