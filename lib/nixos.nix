{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  sys = "x86_64-linux";
in {
  mkHost = path: attrs @ {system ? sys, ...}:
    nixosSystem {
      inherit system;
      specialArgs = {inherit lib inputs system;};
      modules = [
        # Add disko module
        inputs.disko.nixosModules.disko
        # Add installer config for disko
        ({ config, lib, ... }: {
          boot.initrd.systemd.enable = true;
          disko.devices.disk.main.device = lib.mkDefault "/dev/sda";
          boot.loader.efi.canTouchEfiVariables = lib.mkDefault false;
        })
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: v: !elem n ["system"]) attrs)
        ../. # /default.nix
        (import path)
        # Import host-specific disko config if it exists
        (let diskoPath = path + "/disko.nix"; in
          if pathExists diskoPath
          then import diskoPath
          else {})
      ];
    };

  mapHosts = dir: attrs @ {system ? system, ...}:
    mapModules dir
    (hostPath: mkHost hostPath attrs);
}