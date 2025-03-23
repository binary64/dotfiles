# My dotfiles

This is a NixOS (with Flakes) repo.

## Quickstart

1. Download NixOS minimal iso. Etch to a USB memory stick. Boot from it. You should enter into a nixos@nixos shell prompt.
2. Run `git clone https://github.com/binary64/dotfiles` and `cd dotfiles`
3. Run `sudo bash install.sh`
4. Now you have to `sudo nano /mnt/etc/nixos/configuration.nix` and add "git" to system packages.
5. Run `sudo nixos-install --root /mnt --no-root-passwd`
6. Reboot: `cd ~/dotfiles && sudo bash reboot.sh`
7. After rebooting it will boot from the internal disk (sda). Login as root / 123.
8. `cd /etc/nixos` and `rm ./*`
9. Now run `git clone https://github.com/binary64/dotfiles .`
10. Finally, `nixos-rebuild switch --flake .#desktop`

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
