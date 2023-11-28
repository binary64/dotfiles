# My dotfiles

Feel free to roast, install, or skip.

## Quickstart

```bash
nix-shell --packages git --run "git clone git@github.com:binary64/dotfiles.git ~/dotfiles"
cp /etc/nixos/hardware-configuration.nix ~/dotfiles/hosts/<your host name>
sudo nix-channel --update
sudo nixos-rebuild switch --flake ~/dotfiles#<your host name>
sudo reboot now
```

## Features

* Home Manager with Flakes
* tmux

## Wishlist

* WezTerm
* fish
* gnome
* nerdfonts
* neovim
* Wayland
* hyprland
* lazygit
* lf
* bfg
* steam
* chromium
* Wi-Fi

