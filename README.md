# My dotfiles

This is a NixOS (with Flakes) repo.

## Quickstart

1. Download NixOS minimal iso. Etch to a USB memory stick. Boot from it. You should enter into a nixos@nixos shell prompt.
2. Run `git clone https://github.com/binary64/dotfiles` and `cd dotfiles`
3. Run `sudo bash install.sh`
4. Reboot: `sudo reboot now`
5. After rebooting it will boot from the internal disk (sda). Login as root / 123.
6. `cd /etc/nixos` and `rm ./*`
7. Now run `git clone https://github.com/binary64/dotfiles .`
8. Finally, `nixos-rebuild switch --flake .#desktop`

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
