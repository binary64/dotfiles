{ pkgs, config, lib, ... }:

{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
    #./disk-config.nix
  ];

  ## Modules
  modules = {
    shell = {
      git.enable    = true;
    };
  };

  ## Local config
  #programs.ssh.startAgent = true;
  #services.openssh.startWhenNeeded = true;

  networking.networkmanager.enable = true;


}
