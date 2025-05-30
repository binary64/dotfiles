{
  config,
  withSystem,
  mkNixos,
  inputs,
  ...
}: let
  system = "x86_64-linux";
  inherit (config.flake) nixosModules;
in {
  flake.nixosConfigurations.desktop = withSystem system ({pkgs, ...}:
    mkNixos system [
      #-- Topology
      ./configuration.nix
      # nixosModules.es
      # inputs.lanzaboote.nixosModules.lanzaboote
      # nixosModules.tmpfs
      # nixosModules.tpm2
      # nixosModules.user-ayats
      nixosModules.user-user
      # nixosModules.yubikey

      #-- Environment
      {services.displayManager.autoLogin.user = "user";}
      # nixosModules.plasma6
      nixosModules.gnome
      nixosModules.podman

      # #-- Other
      # nixosModules.tailscale
      # nixosModules.guix
      # # nixosModules.docker
      # nixosModules.printing
      # # nixosModules.incus
      # nixosModules.podman
    ]);
}