# My dotfiles

Feel free to roast, install, or skip.

## Quickstart

```bash
git clone git@github.com:binary64/dotfiles.git ~/dotfiles
cp -f /etc/nixos/configuration.nix ~/dotfiles/nixos/configuration.nix.backup
ln -s "${HOME}/home-manager" "${HOME}/dotfiles/home-manager"
sudo ln -s "/etc/nixos/configuration.nix" "${HOME}/dotfiles/nixos/configuration.nix"
sudo nix-channel --update
sudo nixos-rebuild switch
sudo reboot now
```

## Features

* Home Manager with Flakes
* WezTerm
* fish
* gnome
* tmux
* nerdfonts
* neovim
* Wayland

## Wishlist

* hyprland
* lazygit
* lf
* bfg
* steam
* chromium
* Wi-Fi

