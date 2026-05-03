{ config, inputs, ... }:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];
  # programs.dank-material-shell = {
  #   enable = true;
  #
  #   systemd = {
  #     enable = true; # Systemd service for auto-start
  #     restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
  #   };
  #
  #   # Core features
  #   enableSystemMonitoring = true; # System monitoring widgets (dgop)
  #   enableVPN = true; # VPN management widget
  #   enableDynamicTheming = true; # Wallpaper-based theming (matugen)
  #   enableAudioWavelength = true; # Audio visualizer (cava)
  #   enableCalendarEvents = true; # Calendar integration (khal)
  # };
  programs.dank-material-shell = {
    enable = true;
    niri = {
      enableKeybinds = false; # Sets static preset keybinds
      enableSpawn = true; # Auto-start DMS with niri, if enabled
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableClipboardPaste = true;

    settings = {
      theme = "dark";
      currentThemeCategory = "auto";
      blurEnabled = true;
      blurredWallpaperLayer = true;
      blurWallpaperOnOverview = true;
    };

    session = {
      isLightMode = false;
      wallpaperPath = "/home/sand/.nix-config/images/wall.png";
    };

    clipboardSettings = {
      maxHistory = 100;
      maxEntrySize = 5242880;
      autoClearDays = 1;
      clearAtStartup = true;
      disabled = false;
      disableHistory = false;
      disablePersist = true;
    };
  };

  programs.niri = {
    settings = {
      # Enable xwayland-satellite integration
      xwayland-satellite.enable = true;

      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };
          repeat-delay = 220;
          repeat-rate = 150;
          track-layout = "global";
        };

        mouse = {
          accel-speed = 1.0;
          accel-profile = "adaptive";
          scroll-factor = {
            vertical = 1.0;
            horizontal = 1.0;
          };
        };

        # Focus windows and outputs automatically when moving the mouse into them
        focus-follows-mouse.max-scroll-amount = "0%";
      };

      # Output configuration for Virtual-1
      outputs."Virtual-1" = {
        scale = 2.0;
      };

      # Layout settings
      layout = {
        gaps = 8;
        center-focused-column = "never";

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        # Default width of new windows
        default-column-width = {
          proportion = 0.66667;
        };

        # Disable focus ring
        focus-ring.enable = false;

        # Border configuration
        border = with config.lib.stylix.colors.withHashtag; {
          # https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/onedark.yaml
          enable = true;
          width = 2;
          active.gradient = {
            from = base08;
            to = base0D;
            angle = 45;
            in' = "oklch longer hue";
          };
          inactive.gradient = {
            from = base0D;
            to = base0E;
            angle = 45;
          };
        };

        struts = { };

        tab-indicator = {
          place-within-column = true;
          corner-radius = 12;
          gaps-between-tabs = 8;
        };
      };

      prefer-no-csd = true;

      spawn-at-startup = [
        { argv = [ "alacritty" ]; }
        { argv = [ "prlcp" ]; }
      ];

      # Hotkey overlay
      hotkey-overlay = {
        skip-at-startup = true;
      };

      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      # Animation settings
      animations = {
        enable = true;

        workspace-switch = {
          kind.spring = {
            damping-ratio = 1.0;
            stiffness = 1000;
            epsilon = 0.0001;
          };
        };

        window-open = {
          kind.easing = {
            duration-ms = 150;
            curve = "ease-out-expo";
          };
        };

        window-close = {
          kind.easing = {
            duration-ms = 150;
            curve = "ease-out-quad";
          };
        };

        horizontal-view-movement = {
          kind.spring = {
            damping-ratio = 1.0;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };

        window-movement = {
          kind.spring = {
            damping-ratio = 1.0;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };

        window-resize = {
          kind.spring = {
            damping-ratio = 1.0;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };

        config-notification-open-close = {
          kind.spring = {
            damping-ratio = 0.6;
            stiffness = 1000;
            epsilon = 0.001;
          };
        };

        exit-confirmation-open-close = {
          kind.spring = {
            damping-ratio = 0.6;
            stiffness = 500;
            epsilon = 0.01;
          };
        };

        overview-open-close = {
          kind.spring = {
            damping-ratio = 1.0;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };
      };

      # Window rules
      window-rules = [
        # Work around WezTerm's initial configure bug
        {
          matches = [
            {
              app-id = "^org\\.wezfurlong\\.wezterm$";
            }
          ];
          default-column-width = { };
        }
        # Open Firefox picture-in-picture as floating
        {
          matches = [
            {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
        }
        # Default window rule for all windows
        {
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-left = 12.0;
            bottom-right = 12.0;
          };
          clip-to-geometry = true;
        }
      ];

      overview = {
        zoom = 1.0;
      };

      # Key bindings
      binds =
        with config.lib.niri.actions;
        let
          dms-ipc = spawn "dms" "ipc";
        in
        {
          # Terminal and app launcher
          "Alt+W".action.spawn-sh = "niri msg action focus-workspace -- 255 && alacritty";
          "Alt+T".action.spawn-sh = "~/.nix-config/modules/niri/scripts/niri-toggle-term.sh";
          "Mod+G" = {
            action = dms-ipc "spotlight" "toggle";
            hotkey-overlay.title = "Toggle Application Launcher";
          };
          "Ctrl+Shift+V" = {
            action = dms-ipc "clipboard" "toggle";
            hotkey-overlay.title = "Toggle Clipboard Manager";
          };
          "Ctrl+Shift+Return".action.spawn-sh = "alacritty -e ~/.nix-config/modules/niri/scripts/niri-cwd.sh";

          # Overview
          "Alt+O" = {
            action.toggle-overview = { };
            repeat = false;
          };

          # Window management
          "Alt+Q" = {
            action.close-window = { };
            repeat = false;
          };

          # Focus navigation
          "Ctrl+H".action.spawn-sh = "~/.nix-config/modules/niri/scripts/niri-nvim-nav.sh column-left";
          "Ctrl+L".action.spawn-sh = "~/.nix-config/modules/niri/scripts/niri-nvim-nav.sh column-right";
          "Ctrl+J".action.spawn-sh = "~/.nix-config/modules/niri/scripts/niri-nvim-nav.sh window-down";
          "Ctrl+K".action.spawn-sh = "~/.nix-config/modules/niri/scripts/niri-nvim-nav.sh window-up";
          "Ctrl+Shift+K".action.move-window-up-or-to-workspace-up = { };
          "Ctrl+Shift+J".action.move-window-down-or-to-workspace-down = { };

          "Mod+F".action.focus-workspace-down = { };
          "Mod+B".action.focus-workspace-up = { };

          "Alt+9".action.focus-column = 9;
          "Alt+8".action.focus-column = 8;
          "Alt+7".action.focus-column = 7;
          "Alt+6".action.focus-column = 6;
          "Alt+5".action.focus-column = 5;
          "Alt+4".action.focus-column = 4;
          "Alt+3".action.focus-column = 3;
          "Alt+2".action.focus-column = 2;
          "Alt+1".action.focus-column-first = { };
          "Alt+0".action.focus-column-last = { };

          # Workspace navigation with mouse wheel
          "Mod+Alt+Ctrl+Shift+WheelScrollDown" = {
            action.focus-workspace-down = { };
            cooldown-ms = 150;
          };
          "Mod+Alt+Ctrl+Shift+WheelScrollUp" = {
            action.focus-workspace-up = { };
            cooldown-ms = 150;
          };

          # Column navigation with mouse wheel
          "Ctrl+Shift+WheelScrollRight" = {
            action.focus-column-right = { };
            cooldown-ms = 150;
          };
          "Ctrl+Shift+WheelScrollLeft" = {
            action.focus-column-left = { };
            cooldown-ms = 150;
          };

          # Window in/out of column
          "Alt+B" = {
            action.consume-or-expel-window-left = { };
            cooldown-ms = 150;
          };
          "Alt+F" = {
            action.consume-or-expel-window-right = { };
            cooldown-ms = 150;
          };
          "Shift+Right".action.swap-window-right = { };
          "Shift+Left".action.swap-window-left = { };
          "Shift+Up".action.move-window-up = { };
          "Shift+Down".action.move-window-down = { };

          "Alt+Z".action.maximize-column = { };
          "Alt+D".action.move-window-to-workspace = 255;

          # Width adjustments
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";

          # Height adjustments
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          # Tabbed display
          "Mod+W".action.toggle-column-tabbed-display = { };
        };
    };
  };

  programs.zsh = {
    initContent = ''
      if [[ -n $NIRI_SOCKET ]]; then
        . $HOME/.nix-config/modules/niri/niri.zsh
      fi
    '';
  };

  programs.clipsync.enable = true;
}
