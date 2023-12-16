# flake.nix --- the heart of my dotfiles
#
# Author:  Henrik Lissner <contact@henrik.io>
# URL:     https://github.com/hlissner/dotfiles
# License: MIT
#
# Welcome to ground zero. Where the whole flake gets set up and all its modules
# are loaded.

{
  description = "A grossly incandescent nixos config.";

  inputs = 
    {
      # Core dependencies.
      nixpkgs.url = "nixpkgs/nixos-unstable";             # primary nixpkgs
      nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";  # for packages on the edge
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixpkgs";

      # Extras
      nixos-hardware.url = "github:nixos/nixos-hardware";
      #<kickstart-nix.nvim>

      hyprland.url = "github:hyprwm/Hyprland";
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, hyprland, home-manager, ... }:
    let
      inherit (lib.my) mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;  # forgive me Stallman senpai
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
      pkgs  = mkPkgs nixpkgs [ self.overlay ];
      pkgs' = mkPkgs nixpkgs-unstable [];

      lib = nixpkgs.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
    in {
      lib = lib.my;

      overlay =
        final: prev: {
          unstable = pkgs';
          my = self.packages."${system}";
        };

      overlays =
        mapModules ./overlays import;

      packages."${system}" =
        mapModules ./packages (p: pkgs.callPackage p {});

      nixosModules =
        { dotfiles = import ./.; } // mapModulesRec ./modules import;

      nixosConfigurations =
        mapHosts ./hosts {};

      devShell."${system}" =
        import ./shell.nix { inherit pkgs; };

      templates = {
        full = {
          path = ./.;
          description = "A grossly incandescent nixos config";
        };
      } // import ./templates;
      defaultTemplate = self.templates.full;

      defaultApp."${system}" = {
        type = "app";
        program = ./bin/hey;
      };
    };

    #packages.home-manager = home-manager.defaultPackage.${system};




}

