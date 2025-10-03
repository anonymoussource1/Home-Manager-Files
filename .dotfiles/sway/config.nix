{ config, lib, pkgs, ... }: 

{
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
}
