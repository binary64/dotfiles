{ pkgs, config, lib, ... }:

{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = {
    shell = {
      #direnv.enable = true;
      git.enable    = true;
      #gnupg.enable  = true;
      tmux.enable   = true;
    };
  };

  ## Local config
  #programs.ssh.startAgent = true;
  #services.openssh.startWhenNeeded = true;

  networking.networkmanager.enable = true;


}
