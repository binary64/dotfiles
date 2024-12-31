{
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  mkISO = attrs @ {system ? "x86_64-linux", ...}:
    lib.nixosSystem {
      inherit system;
      specialArgs = {inherit lib inputs system;};
      modules = [
        # Import installation-cd module
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        
        # Add disko
        inputs.disko.nixosModules.disko
        
        # Basic ISO configuration
        {
          nixpkgs.pkgs = pkgs;
          
          # Enable flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          # Include git for cloning config
          environment.systemPackages = with pkgs; [
            git
            vim
            curl
            wget
          ];
          
          # Enable OpenSSH for remote installation
          services.openssh.enable = true;
          
          # Set root password for live system
          users.users.root.initialPassword = "nixos";
          
          # Enable systemd in initrd for disko
          boot.initrd.systemd.enable = true;
          
          # ISO-specific settings
          isoImage.makeEfiBootable = true;
          isoImage.makeUsbBootable = true;
        }
      ];
    };
}