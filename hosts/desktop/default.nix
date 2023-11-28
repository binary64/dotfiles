{ pkgs, config, lib, ... }:
{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  #modules = {
  #};

  ## Local config
  #programs.ssh.startAgent = true;
  #services.openssh.startWhenNeeded = true;

  networking.networkmanager.enable = true;


}
