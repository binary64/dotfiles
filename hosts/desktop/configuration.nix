# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./disko-config.nix
    ./hardware-configuration.nix
    ../home.nix

    inputs.disko.nixosModules.disko
  ];

  networking.hostName = "desktop";
  networking.hostId = "00000001";

  users.users.root = {
    initialPassword = "123";
  };

  system.stateVersion = "23.11";
}
