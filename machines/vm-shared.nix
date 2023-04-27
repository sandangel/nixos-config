{ config, pkgs, lib, machine, username, ... }:

{
  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "video=Virtual-1:4112x2572@60" ];
  # Setup qemu so we can run x86_64 binaries
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  # use unstable nix so we can access flakes
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
        "https://hyprland.cachix.org"
        "https://fufexan.cachix.org"
      ];
      trusted-users = [ "root" username ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      ];

      builders-use-substitutes = true;

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;
    };
    extraOptions = ''
      min-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define your hostname.
  networking.hostName = "nixos";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = true;

  # Virtualization settings
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    bip = "192.168.1.0/16";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.wallpaper.mode = "fill";
  services.xserver.desktopManager.gnome = {
    enable = true;
    # These settings are not working in home-manager dconf yet
    extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.keyboard]
      delay=150
      numlock-state=false
      repeat-interval=3

      [org.gnome.desktop.interface]
      clock-show-weekday=true
      color-scheme='prefer-dark'
      cursor-theme='Yaru'
      document-font-name='Noto Sans 11'
      enable-hot-corners=false
      font-antialiasing='grayscale'
      font-hinting='slight'
      font-name='Noto Sans 11'
      gtk-theme='Yaru-dark'
      icon-theme='Yaru-dark'
      monospace-font-name='Comic Code Ligatures 10'
      scaling-factor=2
      text-scaling-factor=1.0

      [org.gnome.desktop.session]
      idle-delay=0
    '';
  };

  environment.gnome.excludePackages = with pkgs.gnome; [
    cheese
    epiphany
    pkgs.gnome-text-editor
    geary
    gnome-calculator
    gnome-contacts
    gnome-music
    pkgs.gnome-photos
    pkgs.gnome-connections
    simple-scan
    totem
  ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
      <monitors version="2">
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>2</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>Virtual-1</connector>
                <vendor>unknown</vendor>
                <product>unknown</product>
                <serial>unknown</serial>
              </monitorspec>
              <mode>
                <width>4112</width>
                <height>2572</height>
                <rate>60.005760192871094</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    ''}"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bind
    binutils
    cachix
    chromium
    firefox
    gcc
    git
    glib
    glxinfo
    gnumake
    home-manager
    killall
    polkit_gnome
    vim
    wl-clipboard
    xdg-utils
    yaru-theme
  ] ++ lib.optionals (machine == "vm-aarch64") [
    gtkmm3
    gtkmm4
  ];

  programs.dconf.enable = true;

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  services.gnome.gnome-browser-connector.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;

  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    comic-code
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    roboto
    roboto-mono
    font-awesome
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
    monospace = [ "Comic Code Ligatures" "Noto Color Emoji" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  # NTP service for automatic time sync
  services.chrony.enable = true;

  # Intall apps using flatpak to avoid recompile
  services.flatpak.enable = true;

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  documentation.nixos.enable = false;

  security.polkit.enable = true;
  security.rtkit.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
