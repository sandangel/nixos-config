# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  # config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  username = "sand";
  comic-code = pkgs.callPackage ../pkgs/comic-code { };
in
{
  boot.kernelParams = [ "video=Virtual-1:4112x2572" ];
  nix = {
    nixPath = [
      "nixpkgs=flake:nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    settings = {
      eval-cores = 2;
      substituters = [
        # "https://hyprland.cachix.org"
        # "https://devenv.cachix.org"
        # "https://cache.flox.dev"
        # "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        # "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        # "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };
  };

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "auto";
      configurationLimit = 30;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;
    # Sometimes the local DNS server stop working
    # So we use the Google Public ones.
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  # Set your time zone.
  # Set to null to allow changing timezone via DBus
  # So GeoIP location detection can work
  time.timeZone = lib.mkForce null;
  # services.automatic-timezoned.enable = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    # GTK theme config
    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };
  };

  # Disable Orca screen reader
  services.orca.enable = false;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  # Gnome config
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  services.desktopManager.gnome.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment = {
    gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];
    systemPackages = with pkgs; [
      # System
      slurp
      umount
      vim
      xdg-utils
      mesa-demos
      gnumake
      gcc

      # Development
      alacritty
      git
      # kitty
      wget
      neovim

      # Need for installing ruby gem sqlite3
      pkg-config

      # Clipboard
      xclip
      wl-clipboard
      clipnotify

      # Niri
      wayland-utils
      nautilus
      chromium
      xwayland-satellite
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      LIBSEAT_BACKEND = "logind";
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      EDITOR = "${pkgs.neovim}/bin/nvim";
      SHELL = "${pkgs.zsh}/bin/zsh";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "Wayland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";

      # GTK theme settings
      GTK_THEME = "Fluent-Dark";

      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QS_ICON_THEME = "Fluent-dark";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      # Ensure icon themes are found
      XCURSOR_THEME = "Fluent-dark-cursors";

      MOZ_ENABLE_WAYLAND = "1";

      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      CHROMIUM_USER_FLAGS = "--force-device-scale-factor=1";
    };
  };

  programs = {
    dconf.enable = true;
    niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    hyprland = {
      enable = false;
      withUWSM = false;
      systemd.setPath.enable = false;
    };
    zsh.enable = true;
    bash.enable = true;
    nix-ld.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dsearch = {
      enable = true;
      systemd.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "gtk"
          "gnome"
        ];
      };
      niri = {
        default = [
          "gtk"
          "gnome"
        ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    xdgOpenUsePortal = true;
  };

  # For Hyprland
  # xdg.portal.config = {
  #   common = {
  #     default = [
  #       "xdph"
  #       "gtk"
  #     ];
  #     "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  #     "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
  #   };
  # };

  # services.desktopManager.cosmic.enable = true;
  # services.desktopManager.cosmic.xwayland.enable = true;

  systemd.user.services = {
    prlcc = {
      serviceConfig = {
        RestartSec = "1";
        Restart = "always";
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = false;
  security.rtkit.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ "sand" ];
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Prerequisite for screensharing
    wireplumber.enable = true;
  };

  fonts.packages = [
    comic-code
  ]
  ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = username;
    description = "San Nguyen";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
    users.${username} =
      { ... }:
      {
        imports = [
          ../users/${username}/home.nix
        ];
        home.stateVersion = "26.05";
      };
  };

  # Install firefox.
  # programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.flatpak = {
    enable = true;
    update.onActivation = true;
    packages = [ ];
  };

  networking.firewall.allowedTCPPorts = [
    22 # Port for SSH Tunnel
    8002 # ADK Web
    3000 # Livekit frontend
    7880 # Livekit RTC server
    5187 # UI
    8000 # Backend
    3005 # Backend with OAuth2
  ];

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.mesa ];

  virtualisation.containerd.enable = true;
  virtualisation.docker = {
    enable = true;
    extraOptions = " --containerd /run/containerd/containerd.sock";
    daemon = {
      settings = {
        live-restore = true;
        features = {
          containerd-snapshotter = true;
        };
      };
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
  # Allow apps to update firmware
  services.fwupd.enable = true;
  # Allow /bin/bash for claude-code plugin scripts
  services.envfs.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
