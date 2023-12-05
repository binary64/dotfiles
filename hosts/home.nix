{ inputs, lib, ... }:

with lib;
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  time.timeZone = mkDefault "Europe/London";
  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  programs = {
    #home-manager = {
    #  enable = true;
    #};
    neovim = {
      enable = true;
    };
    iotop = {
      enable = true;
    };
    hyprland = {
      enable = true;
    };
  };
}
