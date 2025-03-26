# My dotfiles

These are my personal configuration files for my Linux and Windows machines. Feel free to grab anything that you find interesting. This repo is based on viperML/dotfiles -- thank you.

## Quick start

1. Boot NixOS installer iso
2. `git clone https://github.com/binary64/dotfiles && cd dotfiles && bash install.sh`
3. Choose the machine you're installing onto.
4. Enter "y" when prompted to wipe your disk!
5. It will reboot automatically to a non-graphical terminal. Login as root / 123
6. `nixos-rebuild boot --flake /etc/nixos && reboot`
7. It will reboot into a graphical user interface. Login as user / 123

## Features

* NixOS System with Flakes
* ZFS
* Supports multiple machines
* Podman
* Gnome
* Alacritty

## To do list

* Hyprland
* neovim
* Script that runs on boot, does a nixos-rebuild only if noone has yet logged in.
* CICD (GHA) that checks syntax, and then builds an iso
* Desktop notification when a new build is available (with a green pipeline)
* Nvidia stuff
* Newer kernel
* Use the newer nixos-install script, as the old one deprecates soon in 25.05
