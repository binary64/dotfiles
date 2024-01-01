{ config, options, lib, pkgs, ... }:

{
  user.packages = with pkgs; [
    jq
    ripgrep
    fd # find, in rust
    neofetch
podman-compose
];
  virtualisation.oci-containers.backend = "podman";
  virtualisation.containers.registries = {
    search = [ "docker.io" ];
  };
  programs = {
    iotop = {
      enable = true;
    };
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

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {dns_enabled = true;};
    };
  };
}
