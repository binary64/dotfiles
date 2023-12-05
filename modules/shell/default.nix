{ config, options, lib, pkgs, ... }:

{
  user.packages = with pkgs; [
    jq
    ripgrep
    fd # find, in rust
    neofetch

  ];
  programs = {
    iotop = {
      enable = true;
    };
  };
  home.programs = {
    lazygit = {
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
	lf = {
		enable = true;
	};
	fzf = {
		enable = true;
	};
	neovim = {
		enable = true;
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
}
