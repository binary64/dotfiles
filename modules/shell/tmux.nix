{pkgs, ...}: {
  home.programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
    keyMode = "vi";
    prefix = "C-a";
    #terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      #copycat
      #extrakto
      #fuzzback
      catppuccin #nord
      #prefix-highlight
      #tmux-fzf
      #pkgs.tmux-modal
      vim-tmux-navigator
    ];
    extraConfig = ''
      set -sg terminal-overrides ",*:Tc"
      set -g allow-passthrough on
      set -g detach-on-destroy off             # When destory switch to the prev session
      set -g default-shell $SHELL              # use default shell
      set -sg escape-time 5                    # delay shorter
      set -sg history-limit 50000              # increase scrollback
      set -g mouse on                          # enable mouse mode

      #source-file ~/.config/tmux/conf/keybindings.conf

      # left status is only length of 10
      set -g status-left-length 50
    '';
  };
}
