{ pkgs, ...}: {

  imports = [
    ./desktop/hyprland.nix
  ];

#   home = {
#     username = "enzo";
#     homeDirectory = "/home/enzo";
#   };

  home.packages = (with pkgs; [
    
    #User Apps
    celluloid
    librewolf
    cool-retro-term
    bibata-cursors
    #vscode
    lollypop
    lutris
    openrgb

    # discord
    # betterdiscord-installer
    

    #utils
    ranger
    wlr-randr
    git
    rustup
    gnumake
    catimg
    curl
    appimage-run
    xflux
    dunst
    pavucontrol
    sqlite

    #misc 
    cava
    neovim
    nano
    rofi
    nitch
    wget
    grim
    slurp
    wl-clipboard
    pamixer
    mpc-cli
    tty-clock
    eza
    btop
    tokyo-night-gtk

  ]);

#   dconf.settings = {
#     "org/gnome/desktop/interface" = {
#       color-scheme = "prefer-dark";
#     };

#     "org/gnome/shell/extensions/user-theme" = {
#       name = "Tokyonight-Dark-B-LB";
#     };
#   };

  #programs.home-manager.enable = true;

  home.stateVersion = "23.11";
}