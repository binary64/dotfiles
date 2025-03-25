# My dotfiles

These are my personal configuration files for my Linux and Windows machines. Feel free to grab anything that you find interesting. This repo is based on viperML/dotfiles -- thank you.

## Quick start

1. Boot NixOS installer iso
2. `git clone https://github.com/binary64/dotfiles && cd dotfiles && sudo bash install.sh`
3. Type "yes" when prompted, to wipe your disk!
4. It will reboot automatically. Login as root / 123
5. `cd /etc/nixos && sudo git pull && sudo nixos-rebuild switch --flake .#desktop && reboot`
6. ...
