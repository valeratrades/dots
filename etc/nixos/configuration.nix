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
			enable = false;
			autorun = false; # no clue if it does anything if `enable = false`, but might as well keep it
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
		#<home-manager/nixos>
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
		bluetooth.powerOnBoot = false;
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
	};

	systemd = {
		#services = {
		#	"getty@tty1".enable = true;
		#	"autovt@tty1".enable = true;
		#};

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
		ocamlPackages.codicons
		corefonts
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji

		# # copied over for no particular reason:
		dejavu_fonts
		mplus-outline-fonts.githubRelease
		dina-font
		jetbrains-mono
		emojione
		fira-code
		fira-code-symbols
		font-awesome
		google-fonts
		ipafont
		kanji-stroke-order-font
		liberation_ttf
		mplus-outline-fonts.githubRelease
		powerline-fonts
		proggyfonts
		source-code-pro
		ubuntu_font_family
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

		#naersk
		#(naersk.buildPackage {
		#	src = "${userHome}/s/tg";
		#})
		#inputs.helix.packages."${pkgs.system}".helix
		#TODO!: make structure modular, using [flatten](<https://noogle.dev/f/lib/flatten>)
		systemPackages = with pkgs; [
			adwaita-qt
			alacritty
			alsa-utils
			aria2 # better wget
			atool
			atuin
			babelfish
			bemenu
			blueman
			bluez
			bottom
			clang
			clang-tools
			cmake
			cotp
			cowsay
			dbus
			dconf
			difftastic
			dnsutils  # `dig` + `nslookup`
			ethtool
			eww
			eza # better ‘ls’
			fd # better `find`
			file
			fzf
			gawk
			gh
			git
			glib
			gnumake
			gnupg
			gnused
			gnutar
			google-chrome
			grim
			gsettings-desktop-schemas
			haskellPackages.greenclip
			httpie
			iftop # network monitoring
			iotop # io monitoring
			ipcalc  # it is a calculator for the IPv4/v6 addresses
			iperf3
			jq
			keyd
			ldns # replacement of `dig`, it provide the command `drill`
			lean4
			libinput-gestures
			libnotify
			lm_sensors # for `sensors` command
			lsof # list open files
			ltrace # library call monitoring
			lua-language-server
			mako
			mold
			mtr # A network diagnostic tool
			graphviz
			networkmanagerapplet
			nil
			nix-diff
			nixpkgs-fmt
			nmap # A utility for network discovery and security auditing
			p7zip
			pamixer
			pavucontrol
			pciutils # lspci
			pkg-config
			ripgrep
			rofi
			sccache
			slurp
			socat # replacement of openbsd-netcat
			strace # system call monitoring
			swappy
			sysstat
			tmux
			tokei
			tree
			typst
			unzip
			usbutils # lsusb
			mpv
			yazi
			vscode-langservers-extracted #contains jsonls
			wget
			which
			wireplumber
			wl-clipboard
			xorg.xkbcomp
			xz
			yq-go # yaml processor https://github.com/mikefarah/yq
			zip
			zoxide
			zstd

			# Coding {{{
				vscode-extensions.github.copilot
				
				# Editors {{{
					vim
					neovim
					vscode
				#,}}}

				# Shells {{{
					zsh
					fish
					fishPlugins.bass
					dash
				#,}}}
				
				# Language-specific {{{
					# Python {{{
						python3
						python312Packages.pip
						python312Packages.jedi-language-server
						ruff
						ruff-lsp
					#,}}}

					# Golang {{{
						go
						gopls
					#,}}}

					# Rust {{{
						cargo-edit
						cargo-update
						cargo-machete
						cargo-watch
						cargo-nextest
						cargo-limit # brings `lrun` and other `l$command` aliases for cargo, that suppress warnings if any errors are present.
					#,}}}

					typst-lsp
					marksman # md lsp
				#,}}}

				# Debuggers {{{
				lldb
				vscode-extensions.vadimcn.vscode-lldb
				#,}}}

			#,}}}
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


	nix.gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 1w";
	};
	# https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
	nix.settings.auto-optimise-store = true;
	system.stateVersion = "24.05"; #NB: changing requires migration
}