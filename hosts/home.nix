{ lib, ... }:

with lib;
{
  time.timeZone = mkDefault "Europe/London";
  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  programs = {
    neovim = {
      enable = true;
    };
  };
}
