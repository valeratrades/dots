{ config, pkgs, ... }:

let
	unstablePkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
		config = config.nixpkgs.config;
	};
in {
	# TODO please change the username & home directory to your own
	home.username = "v";
	home.homeDirectory = "/home/v";

	# link the configuration file in current directory to the specified location in home directory
	# home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

	# link all files in `./scripts` to `~/.config/i3/scripts`
	# home.file.".config/i3/scripts" = {
	#   source = ./scripts;
	#   recursive = true;   # link recursively
	#   executable = true;  # make all files executable
	# };

	# encode the file content in nix configuration file directly
	# home.file.".xxx".text = ''
	#     xxx
	# '';

	# Things that never need to be available with sudo
	home.packages = with pkgs; [
		cowsay
		spotify
		telegram-desktop
		vesktop
		rnote
		zathura
		ncspot
		neomutt
		neofetch
		figlet
		#unstablePkgs.bash-language-server
		bash-language-server
	];

	gtk = {
		enable = true;
		theme = {
			name = "Materia-dark"; #dbg: Adwaita-dark
			package = pkgs.materia-theme;
		};
	};

	dconf.settings = {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
		};
	};

	home.pointerCursor = {
		name = "Adwaita";
		package = pkgs.adwaita-icon-theme;
		size = 24;
		x11 = {
			enable = true;
			defaultCursor = "Adwaita";
		};
	};

	home.sessionPath = [
		"${pkgs.lib.makeBinPath [ ]}"
		"${config.home.homeDirectory}/s/evdev/"
		"${config.home.homeDirectory}/.cargo/bin/"
		"${config.home.homeDirectory}/go/bin/"
		"/usr/lib/rustup/bin/"
		"${config.home.homeDirectory}/.local/bin/"
		"${config.home.homeDirectory}/pkg/packages.modular.com_mojo/bin"
		"${config.home.homeDirectory}/.local/share/flatpak"
		"/var/lib/flatpak"
	];

	# basic configuration of git, please change to your own
	#programs.git = {
	#  enable = true;
	#  userName = "Ryan Yin";
	#  userEmail = "xiaoyin_c@qq.com";
	#};

	# starship - an customizable prompt for any shell
	#programs.starship = {
	#  enable = true;
	#  # custom settings
	#  settings = {
	#    add_newline = false;
	#    aws.disabled = true;
	#    gcloud.disabled = true;
	#    line_break.disabled = true;
	#  };
	#};

	# alacritty - a cross-platform, GPU-accelerated terminal emulator
	#programs.alacritty = {
	#  enable = true;
	#  # custom settings
	#  settings = {
	#    env.TERM = "xterm-256color";
	#    font = {
	#      size = 12;
	#      draw_bold_text_with_bright_colors = true;
	#    };
	#    scrolling.multiplier = 5;
	#    selection.save_to_clipboard = true;
	#  };
	#};

	#programs.bash = {
	#  enable = true;
	#  enableCompletion = true;
	#  # TODO add your custom bashrc here
	#  bashrcExtra = ''
	#    export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
	#  '';
	#
	#  # set some aliases, feel free to add more or remove some
	#  shellAliases = {
	#    k = "kubectl";
	#    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
	#    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
	#  };
	#};
	programs.fish.enable = true;

	# This value determines the home Manager release that your
	# configuration is compatible with. This helps avoid breakage
	# when a new home Manager release introduces backwards
	# incompatible changes.
	#
	# You can update home Manager without changing this value. See
	# the home Manager release notes for a list of state version
	# changes in each release.

	programs.home-manager.enable = true; # let it manage itself
	home.stateVersion = "24.05"; #NB: DO NOT CHANGE, same as `system.stateVersion`
}
