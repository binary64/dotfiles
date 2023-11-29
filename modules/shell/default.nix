{ config, options, lib, pkgs, ... }:

{
  user.packages = with pkgs; [
    jq
    lf
    fzf
    ripgrep
    fd # find, in rust
    neofetch
  ];
  home.programs = {
    lazygit = {
      enable = true;
    };
    zoxide = {
      enable = true;
    };
    man = {
      enable = true;
    };
    bat = {
      enable = true;
    };
    btop = {
      enable = true;
    };
  };
}
