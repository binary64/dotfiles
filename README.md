# My dotfiles

Feel free to roast, install, or skip.

## Quickstart

```bash
nix-shell --packages git --run "git clone git@github.com:binary64/dotfiles.git ~/dotfiles"
cp /etc/nixos/configuration.nix ~/dotfiles/nixos/configuration.nix.backup
sudo ln -sf "${HOME}/dotfiles/nixos/configuration.nix" "/etc/nixos/configuration.nix"
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

