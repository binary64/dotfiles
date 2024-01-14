{pkgs, ...}: {
  imports = [
    ./desktop
    ./terminal
    ../packages/fish
  ];

  #   home = {
  #     username = "enzo";
  #     homeDirectory = "/home/enzo";
  #   };
  #home.shellAliases = {
  #  ls = "${pkgs.eza}/bin/eza";
  #};
  home.packages = with pkgs; [
    oscclip
    #User Apps
    #celluloid
    librewolf
    #cool-retro-term
    bibata-cursors
    #vscode
    #lollypop
    #lutris # wat, this requires steam (non-free)
    #openrgb

    # discord
    # betterdiscord-installer

    #utils
    ranger
    wlr-randr
    rustup
    gnumake
    #catimg
    curl
    appimage-run
    #xflux
    dunst
    #pavucontrol
    sqlite

    #misc
    #cava
    #neovim
    nano
    rofi
    #nitch
    wget
    #grim
    #slurp
    wl-clipboard
    pamixer
    mpc-cli
    tty-clock
    eza
    btop
    tokyo-night-gtk
  ];

  #   dconf.settings = {
  #     "org/gnome/desktop/interface" = {
  #       color-scheme = "prefer-dark";
  #     };

  #     "org/gnome/shell/extensions/user-theme" = {
  #       name = "Tokyonight-Dark-B-LB";
  #     };
  #   };

  #programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "binary64";
    userEmail = "1680627+binary64@users.noreply.github.com";
  };

  programs = {
    nixvim = {
      enable = true;

      colorschemes.catppuccin.enable = true;
      #plugins.lightline.enable = true;
    };
  };

  home.stateVersion = "23.11";
}
