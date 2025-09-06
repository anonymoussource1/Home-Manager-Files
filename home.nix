{ config, pkgs, lib, ... }:

{
	# Home Manager needs a bit of information about you and the paths it should
	# manage.
	home.username = "danielkurz";
	home.homeDirectory = "/home/danielkurz";

	# This value determines the Home Manager release that your configuration is
	# compatible with. This helps avoid breakage when a new Home Manager release
	# introduces backwards incompatible changes.
	#
	# You should not change this value, even if you update Home Manager. If you do
	# want to update the value, then make sure to first check the Home Manager
	# release notes.
	home.stateVersion = "23.11"; # Please read the comment before changing.
	
	# The home.packages option allows you to install Nix packages into your
	# environment.
	home.packages = with pkgs; [
		# # Adds the 'hello' command to your environment. It prints a friendly
		# # "Hello, world!" when run.
		# pkgs.hello
		
		# # It is sometimes useful to fine-tune packages, for example, by applying
		# # overrides. You can do that directly here, just don't forget the
		# # parentheses. Maybe you want to install Nerd Fonts with a limited number of
		# # fonts?
		# (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
		
		# # You can also create simple shell scripts directly inside your
		# # configuration. For example, this adds a command 'my-hello' to your
		# # environment:
		# (pkgs.writeShellScriptBin "my-hello" ''
		#   echo "Hello, ${config.home.username}!"
		# '')
		tree
		i3blocks
		cargo
		rustc
		bc
		gimp3
		dex
		cowsay
		kdePackages.okular
		(flameshot.override { enableWlrSupport = true; })
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
		".config/eww".source = .dotfiles/eww;
		".config/kitty".source = .dotfiles/kitty;
		".config/vim".source = .dotfiles/vim;
	};
	
	programs.bash = {
		enable = true;
		profileExtra = ''
			. ~/.bash_prompt
			sway
		'';
	};

	wayland.windowManager.sway = {
		enable = true;
		config = {
			modifier = "Mod4";
			terminal = "kitty";
			menu = "eww open launcher";
			fonts = {
				names = [ "BigBlueTermPlusNerdFont" ];
				style = "Medium";
				size = 12.0;
			};
			output = {
				"*" = {
					bg = "#1B1B17 solid_color";
				};
			};
			input = {
				"type:keyboard" = {
					xkb_options = "caps:escape";
					xkb_layout = "us(altgr-intl)";
				};
				"type:touchpad" = {
					dwt = "enabled";
					click_method = "clickfinger";
					clickfinger_button_map = "lrm";
					drag = "enabled";
					tap = "enabled";
					tap_button_map = "lrm";
				};
			};
			gaps = {
				inner = 5;
				outer = 5;
			};
			startup = [
				{ command = "eww open bar"; always = true; }
				{ command = "kitty"; }
				{ command = "flatpak run app.zen_browser.zen"; }
			];
			defaultWorkspace = "workspace number 1";
			assigns = {
				"1" = [{ app_id = "kitty"; }];
				"2" = [{ app_id = "zen"; }];
				"3" = [{ app_id = "spotify"; }];
			};
			window = {
				border = 0;
				titlebar = false;
				commands = [
					{ command = "inhibit_idle fullscreen"; criteria = { app_id = "."; }; }
				];
			};
			bars = [];
			keybindings = let
				modifier = config.wayland.windowManager.sway.config.modifier;
			in lib.mkOptionDefault {
				"--locked XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
				"--locked XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
				"--locked XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
				"--locked XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
				"--locked XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
				"--locked XF86AudioPlay" = "exec playerctl play-pause";
				"--locked XF86AudioNext" = "exec playerctl next";
				"--locked XF86AudioPrev" = "exec playerctl previous";
				"${modifier}+P" = "exec flameshot gui";
			};
			colors = let
				focused = "#2B2B27";
				unfocused = "#1E1E1E";
				inactive = "#505149";
				urgent = "#AA5042";
				text = "#336631";
				unfocused_text = "#223320";
				inactive_text = "#354033";
			in {
				focused = {
					border = focused; 
					background = focused;
					text = text;
					indicator = focused;
					childBorder = focused;
				};
				unfocused = {
					border = unfocused; 
					background = unfocused;
					text = unfocused_text;
					indicator = unfocused;
					childBorder = unfocused;
				};
				focusedInactive = {
					border = inactive; 
					background = inactive;
					text = inactive_text;
					indicator = inactive;
					childBorder = inactive;
				};
				urgent = {
					border = urgent; 
					background = urgent;
					text = text;
					indicator = urgent;
					childBorder = urgent;
				};
			};
		};
	};

	services.swayidle = let 
		lock = "${pkgs.swaylock}/bin/swaylock -feF -i ~/Backgrounds/bg.jpg --font BigBlueTermPlusNerdFont";
		display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
	in {
		enable = true;
		timeouts = [
			{ timeout = 60; command = lock; }
			{ timeout = 120; command = display "off"; resumeCommand = display "on"; }
			{ timeout = 135; command = "systemctl suspend"; }
		];
		events = [
			{ event = "before-sleep"; command = lock; }
		];
	};
		
	


	/*home.pointerCursor = 
		let 
			getFrom = url: hash: name: {
				sway.enable = true;
				name = name;
				size = 48;
				package = pkgs.runCommand "moveUp" {} ''
					mkdir -p $out/share/icons
					ln -s ${pkgs.fetchzip {
						url = url;
						hash = hash;
					}} $out/share/icons/${name}
					'';
			};
		in getFrom 
			"https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.0/Fuchsia-Pop.tar.gz"
			"sha256-BvVE9qupMjw7JRqFUj1J0a4ys6kc9fOLBPx2bGaapTk="
			"Fuchsia-Pop";
*/

	
	# Home Manager can also manage your environment variables through
	# 'home.sessionVariables'. If you don't want to manage your shell through Home
	# Manager then you have to manually source 'hm-session-vars.sh' located at
	# either
	#
	#  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
	#
	# or
	#
	#  /etc/profiles/per-user/danielkurz/etc/profile.d/hm-session-vars.sh
	#
	home.sessionVariables = {
		EDITOR = "vim";
		PATH="$PATH:/home/danielkurz/.bin";
		TERMINAL="kitty";
	};

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;
}
