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
    ./disko.nix
    ./hardware-configuration.nix

    inputs.disko.nixosModules.disko
  ];

  networking.hostName = "desktop";
  networking.hostId = "00000001";

  users.users.root = {
    initialPassword = "123";
  };

  time.timeZone = mkDefault "Europe/London";
  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  console.keyMap = "uk";

  system.stateVersion = "23.11";
}
