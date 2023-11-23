# My dotfiles

Feel free to roast, install, or skip.

## Quickstart

```bash
git clone git@github.com:binary64/dotfiles.git ~/dotfiles
cd ~/dotfiles
ln -s "${HOME}/home-manager" "${HOME}/dotfiles/home-manager"
sudo ln -s "/etc/nixos/configuration.nix" "${HOME}/dotfiles/nixos/configuration.nix"
sudo nixos-rebuild switch
home-manager switch
sudo reboot now
```

If you are paranoid, mix these in:

```bash
cp -f /etc/nixos/configuration.nix ~/dotfiles/nixos/
cp -fr ~/home-manager ~/dotfiles
git diff
```

## Features

* WezTerm
* fish
* gnome
* tmux
* nerdfonts
* neovim
* Home Manager with Flakes
* Wayland

## Wishlist

* hyprland
* lazygit
* lf
* bfg
* steam
* chromium
* Wi-Fi

