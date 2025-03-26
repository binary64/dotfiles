{
  inputs,
  config,
  withSystem,
  ...
}:
{
  imports = [
    ./desktop
    ./hermes
    ./fatalis
    ./zorah
  ];

  _module.args.mkNixos =
    system: extraModules:
    let
      specialArgs = withSystem system (
        {
          inputs',
          self',
          ...
        }:
        {
          inherit self' inputs' inputs;
        }
      );
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;

      modules = [
        #-- Core
        inputs.nixpkgs.nixosModules.readOnlyPkgs
        { nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs); }

        config.flake.nixosModules.common
        inputs.nix-common.nixosModules.default

        inputs.noshell.nixosModules.default
        # { programs.noshell.enable = true; }

        inputs.activation-manager.nixosModules.home

        (
          { config, lib, ... }:
          {
            users.users.user.packages = [
              (config.activation-manager.mkHome ../modules/activation-manager/main.nix)

              htop
            ];

            i18n.defaultLocale = "en_GB.UTF-8";
            console = {
              # font = "Lat2-Terminus16";
              keyMap = lib.mkForce "uk";
              useXkbConfig = true; # use xkb.options in tty.
            };
          }
        )
      ] ++ extraModules;
    };
}
