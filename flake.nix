{
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        config,
        ...
      }:
      {
        imports = [
          ./packages
          ./misc/lib
          ./hosts
        ];

        flake = {
          nixosModules = config.flake.lib.dirToAttrs ./modules/nixos;
        };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        perSystem =
          {
            pkgs,
            config,
            ...
          }:
          {
            devShells.default =
              with pkgs;
              mkShellNoCC {
                packages = [
                  lua-language-server
                  config.packages.stylua
                  taplo
                ];
              };
          };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    
  };

  
}