{ config, pkgs, inputs, ... }:

{
  programs = {
    home-manager.enable = true;

    tmux = {
      enable = true;
      baseIndex = 1;
      shortcut = "a";
      terminal = "tmux-direct";
      plugins = [ pkgs.tmuxPlugins.nord ];
      #extraConfig = ''
      #  set -g default-terminal "tmux-256color"
      #  set -ag terminal-overrides ",xterm-256color:RGB"
      #'';
    };

    wezterm.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    bash.enable = true;

    #zellij = {
    #  enable = true;
    #  enableBashIntegration = true;
    #  enableFishIntegration = true;
    #};

    git = {
      enable = true;
      userEmail = "1680627+binary64@users.noreply.github.com";
      userName = "binary64";
      aliases = {
          s = "status";
          l = "log";
      };
      ignores = [ "*.swp" "*.log" "*.pdf" "*.aux" "*.out" ];
    };
  };

#  programs.fish = {
#    enable = true;  # Ensure Fish is enabled
#    shellInit = ''
#    '';
#  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "user";
  home.homeDirectory = "/home/user";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    hello
    htop
    git
    curl
    wget
    ripgrep


go
rustup
k3d
nodejs
inputs.neovim-flake.packages.${pkgs.system}.nvim
nodePackages.degit
nodePackages.pnpm
git-standup
gitui

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    (writeShellScriptBin "my-hello" ''
      echo "Hello, ${config.home.username}!"
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/user/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    #EDITOR = "nvim";
    SHELL = "${pkgs.fish}";
  };

}