{ config, pkgs, lib, ... }:

{
  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "virtio-gpu" ];
  boot.kernelParams = [ "video=Virtual-1:4112x2572@60" ];

  # use unstable nix so we can access flakes
  nix = {
    package = pkgs.nixUnstable;
    autoOptimiseStore = true;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      min-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # We expect to run the VM on hidpi machines.
  hardware.video.hidpi.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.efi.canTouchEfiVariables = true;

  # Define your hostname.
  networking.hostName = "nixos";

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = true;

  # Virtualization settings
  virtualisation.docker.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.dpi = 254;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.wallpaper.mode = "fill";
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.keyboard]
      repeat-interval=3
      delay=200

      [org.gnome.desktop.wm.keybindings]
      activate-window-menu=[]
      begin-move=[]
      begin-resize=[]
      close=[]
      cycle-group=[]
      cycle-group-backward=[]
      cycle-panels=[]
      cycle-panels-backward=[]
      cycle-windows=[]
      cycle-windows-backward=[]
      maximize=[]
      minimize=[]
      move-to-monitor-down=[]
      move-to-monitor-left=[]
      move-to-monitor-right=[]
      move-to-monitor-up=[]
      move-to-workspace-down=[]
      move-to-workspace-last=[]
      move-to-workspace-left=[]
      move-to-workspace-right=[]
      move-to-workspace-up=[]
      panel-run-dialog=[]
      switch-applications=[]
      switch-applications-backward=[]
      switch-group=[]
      switch-group-backward=[]
      switch-input-source=[]
      switch-input-source-backward=[]
      switch-panels=[]
      switch-panels-backward=[]
      switch-to-workspace-1=[]
      switch-to-workspace-down=[]
      switch-to-workspace-last=[]
      switch-to-workspace-left=[]
      switch-to-workspace-right=[]
      switch-to-workspace-up=[]
      toggle-maximized=[]
      unmaximize=[]

      [org.gnome.settings-daemon.plugins.power]
      sleep-inactive-battery-timeout=0
      sleep-inactive-battery-type='nothing'
      sleep-inactive-ac-timeout=0
      sleep-inactive-ac-type='nothing'
      power-saver-profile-on-low-battery=false
      power-button-action='nothing'
      idle-dim=false
      ambient-enabled=false

      [org.gnome.desktop.session]
      idle-delay=0

      [org.gnome.settings-daemon.plugins.xsettings]
      overrides={'Gdk/WindowScalingFactor': <2>}

      [org.gnome.desktop.interface]
      scaling-factor=2

      [org.gnome.mutter]
      overlay-key='Super_R'
    '';

    extraGSettingsOverridePackages = with pkgs; [
      gsettings-desktop-schemas
      gnome.gnome-shell
      gnome.mutter
    ];
  };

  environment.gnome.excludePackages = with pkgs.gnome; [
    cheese
    eog
    epiphany
    evince
    pkgs.gnome-text-editor
    geary
    gnome-calculator
    gnome-contacts
    gnome-maps
    gnome-music
    pkgs.gnome-photos
    pkgs.gnome-connections
    simple-scan
    totem
    yelp
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
    gnumake
    killall
    wl-clipboard
    xclip
    gnome.dconf-editor
    gnome.gnome-tweaks
    yaru-theme
    vim
    gcc
    git
    home-manager
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;

  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    fira-code
    comic-code
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "no";

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  documentation.nixos.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
