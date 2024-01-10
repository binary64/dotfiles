{
  config,
  options,
  lib,
  pkgs,
  ...
}: {
  user.packages = with pkgs; [
    jq
    ripgrep
    fd # find, in rust
    neofetch
    podman-compose
    iotop-c
  ];
  virtualisation.oci-containers.backend = "podman";
  virtualisation.containers.registries = {
    search = ["docker.io"];
  };
  programs = {
    fish = {
      enable = true;
    };
  };
  users.defaultUserShell = pkgs.fish;
  home.programs = {
    starship = {
      enable = true;
    };
    direnv = {
      enable = true;
    };
    fish = {
      enable = true;
      shellAliases = {
        g = "gitui";
        gs = "git status";
        lg = "lazygit";
        gacp = "git add -A && git commit --no-verify && git push --no-verify";
        gp = "git push --no-verify";
      };
    };
    eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
    };
    lazygit = {
      enable = true;
    };
    gitui = {
      enable = true;
    };
    zoxide = {
      enable = true;
    };
    man = {
      enable = true;
    };
    bat = {
      enable = true;
    };
    btop = {
      enable = true;
    };
    bash = {
      enable = true;
    };
    less = {
      enable = true;
    };
    helix = {
      enable = true;
    };
    htop = {
      enable = true;
    };
    fzf = {
      enable = true;
      tmux = {enableShellIntegration = true;};
      #package = pkgs.unstable.fzf;
      enableFishIntegration = true;
      defaultOptions = [
        # theme
        # source: https://github.com/catppuccin/fzf
        "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
        "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
        "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

        "--no-height"
        "--tabstop=2"
        "--cycle"
        "--layout=default"
        "--no-separator"
        "--scroll-off=4"
        "--prompt='❯ '"
        "--marker='❯'"
        "--pointer='❯'"

        # mappings
        "--bind 'ctrl-d:preview-half-page-down'"
        "--bind 'ctrl-u:preview-half-page-up'"
        "--bind 'ctrl-e:abort'"
        "--bind 'ctrl-y:accept'"
        "--bind 'ctrl-f:half-page-down'"
        "--bind 'ctrl-b:half-page-up'"
        "--bind '?:toggle-preview'"
      ];
      # CTRL-T - Paste the selected file path(s) into the command line
      fileWidgetOptions = [
        "--preview '(bat --style=numbers --color=always {} || lsd -l -A --ignore-glob=.git --tree --depth=2 --color=always --blocks=size,name {}) 2> /dev/null | head -200'"
        "--preview-window 'right:border-left:50%:<40(right:border-left:50%:hidden)'"
      ];
      # CTRL-R - Paste the selected command from history into the command line
      historyWidgetOptions = [
        "--preview 'echo {} | sed \\\"s/^ *\\([0-9|*]\\+\\) *//\\\" | bat --plain --language=sh --color=always'"
        "--preview-window 'down:border-top:4:<4(down:border-top:4:hidden)'"
      ];
      # ALT-C - cd into the selected directory
      changeDirWidgetOptions = [
        "--preview 'lsd -l -A --ignore-glob=.git --tree --depth=2 --color=always --blocks=size,name {} | head -200'"
        "--preview-window 'right:border-left:50%:<40(right:border-left:50%:hidden)'"
      ];
    };
    tealdeer = {
      enable = true;
    };
    ssh = {
      enable = true;
    };
    zsh = {
      enable = true;
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {dns_enabled = true;};
    };
  };
}
