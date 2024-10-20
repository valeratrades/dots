# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

#TODO: add build script that cds in $XDG_DATA_HOME/nvim/lazy-telescope-fzf-native.nvim and runs `make`

let
	userHome = config.users.users.v.home;

	modularHome = "${userHome}/.modular";

	systemdCat = "${pkgs.systemd}/bin/systemd-cat";
	sway = "${config.programs.sway.package}/bin/sway";
in
	{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	services = {
		xserver = {
			enable = true;
			autorun = false; #dbg: trying out. May or may not help with lightdm
			xkb = {
				extraLayouts.semimak = {
					description = "Semimak for both keyboard standards";
					languages = [ "eng" ];
					symbolsFile = /usr/share/X11/xkb/symbols/semimak;
				};
				layout = "semimak";
				variant = "iso";
				options = "grp:win_space_toggle";
			};
		};
		#displayManager.enable = lib.mkForce false; # disables lightdm (hopefully)
		#displayManager.lightdm.enable = false; # disables lightdm (hopefully)

		keyd.enable = true;
		#xwayland.enable = true;

		pipewire = {
			enable = true;
			alsa = {
				enable = true;
				support32Bit = true;
			};
			pulse.enable = true;
			jack.enable = true;
			wireplumber.enable = true;
		};

		printing.enable = true;
		libinput.enable = true;
		#openssh.enable = true;
		blueman.enable = true;
	};
	programs = {
		bash = {
			loginShellInit = ''
			if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty4" ]; then
				# https://wiki.archlinux.org/title/Sway#Automatically_on_TTY_login
				#exec ${systemdCat} --identifier=sway ${sway}
				exec /usr/bin/start_sway.sh
			fi
			'';
		};

		firefox.enable = true;
		sway = {
			enable = true;
			wrapperFeatures.gtk = true;
		};
		sway.xwayland.enable = true;
		fish.enable = true;

		mtr.enable = true;
		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
		};
	};
	xdg.portal.wlr.enable = true;


	imports = [
		./hardware-configuration.nix
		<home-manager/nixos>
	];


	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	#boot.loader.grub.useOsProber = true;

	# Set your time zone.
	time.timeZone = "Europe/Paris";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "fr_FR.UTF-8";
		LC_IDENTIFICATION = "fr_FR.UTF-8";
		LC_MEASUREMENT = "fr_FR.UTF-8";
		LC_MONETARY = "fr_FR.UTF-8";
		LC_NAME = "fr_FR.UTF-8";
		LC_NUMERIC = "fr_FR.UTF-8";
		LC_PAPER = "fr_FR.UTF-8";
		LC_TELEPHONE = "fr_FR.UTF-8";
		LC_TIME = "en_GB.UTF-8";
	};

	hardware = {
		pulseaudio.enable = false;
		bluetooth.enable = true;
		#bluetooth.powerOnBoot
	};

	security = {
		sudo = {
			enable = true;
			extraConfig = ''
			%wheel ALL=(ALL) NOPASSWD: ALL
			'';
		};
		rtkit.enable = true;
		polkit.enable = true;
	};

	users.users.v = {
		isNormalUser = true;
		description = "v";
		shell = pkgs.fish;
		extraGroups = [ "networkmanager" "wheel" "keyd" "audio" "video" ];
		# Things that never need to be available with sudo
		packages = with pkgs; [
			spotify
			telegram-desktop
			vesktop
			rnote
			zathura
			ncspot
			neomutt
			neofetch
			figlet
		];
	};
	home-manager =
	{
		users.v = { pkgs, ...}: let
			unstablePkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
				config = config.nixpkgs.config;
			};
		in {
			home.packages = [
				pkgs.atool
				pkgs.httpie
				unstablePkgs.bash-language-server
				#unstablePkgs.wl-gammactl-unstable
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
				"${userHome}/s/evdev/"
				"${userHome}/.cargo/bin/"
				"${userHome}/go/bin/"
				"/usr/lib/rustup/bin/"
				"${userHome}/.local/bin/"
				"${modularHome}/pkg/packages.modular.com_mojo/bin"
				"${userHome}/.local/share/flatpak"
				"/var/lib/flatpak"
			];


			programs.fish.enable = true;

			home.stateVersion = "24.05"; #NB: DO NOT CHANGE, same as `system.stateVersion`
		};
		backupFileExtension = "hm-backup";
		useGlobalPkgs = true;
	};

	systemd = {
		services = {
			"getty@tty1".enable = true;
			"autovt@tty1".enable = true;
		};

		user.services.mpris-proxy = {
			description = "Mpris proxy";
			after = [ "network.target" "sound.target" ];
			wantedBy = [ "default.target" ];
			serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
		};
	};

	fonts.packages = with pkgs; [
		nerdfonts	
		font-awesome

		# # copied over for no particular reason:
		google-fonts
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		liberation_ttf
		fira-code
		fira-code-symbols
		mplus-outline-fonts.githubRelease
		dina-font
		proggyfonts
		#
	];

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	environment = {
		# XDG directories and Wayland environment variables setup
		variables = {
			XDG_DATA_HOME = "${userHome}/.local/share";
			XDG_CONFIG_HOME = "${userHome}/.config";
			XDG_CACHE_HOME = "${userHome}/.cache";
			XDG_CURRENT_DESKTOP = "sway";
			QT_WAYLAND_FORCE_DPI = "physical";
			GDK_BACKEND = "wayland";
			QT_QPA_PLATFORM = "wayland-egl";
			CLUTTER_BACKEND = "wayland";
			SDL_VIDEODRIVER = "wayland";
			BEMENU_BACKEND = "wayland";
			MOZ_ENABLE_WAYLAND = "1";

			# Other specific environment variables
			GIT_CONFIG_HOME = "${userHome}/.config/git/config";
			QT_QPA_PLATFORMTHEME = "flatpak";
			GTK_USE_PORTAL = "1";
			GDK_DEBUG = "portals";

			# home vars
			MODULAR_HOME = "${modularHome}";
			#PATH = "${pkgs.lib.makeBinPath [ ]}:${userHome}/s/evdev/:${userHome}/.cargo/bin/:${userHome}/go/bin/:/usr/lib/rustup/bin/:${userHome}/.local/bin/:${modularHome}/pkg/packages.modular.com_mojo/bin:${userHome}/.local/share/flatpak:/var/lib/flatpak";
			EDITOR = "nvim";
			WAKETIME = "5:00"; 
			DAY_SECTION_BORDERS = "2.5:10.5:16";
			PAGER = "less";
			MANPAGER = "less";
			LESSHISTFILE = "-";
			HISTCONTROL = "ignorespace";
		};

		shellInit = ''
		sudo ln -sfT ${pkgs.dash}/bin/dash /bin/sh
		'';

		systemPackages = with pkgs; [
			#naersk
			#(naersk.buildPackage {
			#	src = "${userHome}/s/tg";
			#})
			#inputs.helix.packages."${pkgs.system}".helix

			adwaita-qt
			pkg-config
			adwaita-qt
			alacritty
			alsa-utils
			atuin
			babelfish
			bemenu
			blueman
			blueman
			mold
			sccache
			bluez
			clang
			clang-tools
			cmake
			dash
			dbus
			dconf
			eww
			eza
			fd
			fish
			fishPlugins.bass
			fzf
			difftastic
			gawk
			gh
			git
			glib
			gnumake
			go
			google-chrome
			gopls
			grim
			gsettings-desktop-schemas
			haskellPackages.greenclip
			jq
			keyd
			lean4
			libinput-gestures
			libnotify
			lua-language-server
			mako
			marksman
			neovim
			networkmanagerapplet
			nil
			nix-diff
			nixpkgs-fmt
			pamixer
			pavucontrol
			python3
			python312Packages.jedi-language-server
			python312Packages.pip
			ripgrep
			rofi
			ruff-lsp
			ruff
			rustup # should I?
			slurp
			swappy
			tmux
			tokei
			typst
			typst-lsp
			vim
			vscode-langservers-extracted #contains jsonls
			wget
			wireplumber
			wl-clipboard
			xorg.xkbcomp
			zoxide
			zsh
		];
	};

	networking = {
		# for spotify:
		firewall.allowedTCPPorts = [ 57621 /*for spotify*/];
		firewall.allowedUDPPorts = [ 5353 /*for spotify*/];

		hostName = "nixos"; # Define your hostname.
		networkmanager.enable = true;
		# networking.proxy.default = "http://user:password@proxy:port/";
		# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
	};

	system.stateVersion = "24.05"; #NB: changing requires migration
}
