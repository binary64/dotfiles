# My dotfiles

This is a NixOS (with Flakes) repo.

## Quickstart

1. Download NixOS minimal iso. Etch to a USB memory stick. Boot from it. You should enter into a nixos@nixos shell prompt.
2. Run `git clone https://github.com/binary64/dotfiles` and `cd dotfiles`
3. Run `sudo bash install.sh`
4. Run `sudo nixos-install --root /mnt --flake ".#desktop" --no-root-passwd`
5. Reboot: `sudo reboot now`

## Features

- zfs

## Wishlist

- WezTerm
- fish
- gnome
- nerdfonts
- neovim
- hyprland
- lazygit
- lf
- bfg
- steam
- chromium
- Wi-Fi
