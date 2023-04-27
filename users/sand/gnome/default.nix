{ pkgs, lib, ... }:
{
  gtk = {
    enable = true;

    iconTheme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };

    theme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };

    cursorTheme = {
      name = "Yaru";
      package = pkgs.yaru-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.sessionVariables.GTK_THEME = "Yaru-dark";
  home.packages = with pkgs; [
    yaru-theme
    gnome.dconf-editor
    gnome.gnome-tweaks
    # These extensions are installed by chromium
    # gnomeExtensions.blur-my-shell
    # gnomeExtensions.forge
    # gnomeExtensions.logo-menu
    # gnomeExtensions.space-bar
    # gnomeExtensions.top-bar-organizer
    # gnomeExtensions.transparent-shell
    # gnomeExtensions.user-themes
  ];

  dconf.settings = {
    "org/gnome/GWeather4" = {
      temperature-unit = "centigrade";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///nix-config/images/wall.png";
      picture-uri-dark = "file:///nix-config/images/wall.png";
      primary-color = "#528bff";
      secondary-color = "#98c379";
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///nix-config/images/wall.png";
      primary-color = "#528bff";
      secondary-color = "#98c379";
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = 30;
      recent-files-max-age = -1;
    };

    "org/gnome/desktop/sound" = {
      theme-name = "Yaru";
    };

    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = [ ];
      begin-move = [ ];
      begin-resize = [ ];
      close = [ ];
      cycle-group = [ ];
      cycle-group-backward = [ ];
      cycle-panels = [ ];
      cycle-panels-backward = [ ];
      cycle-windows = [ ];
      cycle-windows-backward = [ ];
      maximize = [ ];
      minimize = [ ];
      move-to-monitor-down = [ ];
      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      move-to-monitor-up = [ ];
      move-to-workspace-1 = [ ];
      move-to-workspace-down = [ ];
      move-to-workspace-last = [ ];
      move-to-workspace-left = [ ];
      move-to-workspace-right = [ ];
      move-to-workspace-up = [ ];
      panel-run-dialog = [ ];
      switch-applications = [ ];
      switch-applications-backward = [ ];
      switch-group = [ ];
      switch-group-backward = [ ];
      switch-input-source = [ ];
      switch-input-source-backward = [ ];
      switch-panels = [ ];
      switch-panels-backward = [ ];
      switch-to-workspace-1 = [ ];
      switch-to-workspace-down = [ ];
      switch-to-workspace-last = [ ];
      switch-to-workspace-left = [ "<Super>b" ];
      switch-to-workspace-right = [ "<Super>n" ];
      switch-to-workspace-up = [ ];
      toggle-maximized = [ ];
      unmaximize = [ ];
    };

    "org/gnome/desktop/wm/preferences" = {
      mouse-button-modifier = "disabled";
      titlebar-font = "Noto Sans Bold 11";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      edge-tiling = false;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ ];
      toggle-tiled-right = [ ];
    };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      help = [ ];
      logout = [ ];
      magnifier = [ ];
      magnifier-zoom-in = [ ];
      magnifier-zoom-out = [ ];
      screenreader = [ ];
      screensaver = [ ];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
      idle-dim = false;
      power-button-action = "nothing";
      power-saver-profile-on-low-battery = false;
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-timeout = 0;
      sleep-inactive-battery-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" "logomenu@aryan_k" "space-bar@luchrioh" "transparent-shell@siroj42.github.io" "top-bar-organizer@julian.gse.jsts.xyz" "transparent-top-bar@ftpix.com" "forge@jmmaranan.com" "blur-my-shell@aunetx" ];
      favorite-apps = [ "org.gnome.Calendar.desktop" "org.gnome.Nautilus.desktop" "firefox.desktop" "org.gnome.Extensions.desktop" "org.gnome.Settings.desktop" "kitty.desktop" "gnome-system-monitor.desktop" "org.gnome.tweaks.desktop" "org.gnome.baobab.desktop" "ca.desrt.dconf-editor.desktop" ];
    };

    "org/gnome/shell/extensions/Logo-menu" = {
      hide-softwarecentre = true;
      menu-button-icon-click-type = 3;
      menu-button-icon-image = 32;
      menu-button-icon-size = 20;
      menu-button-terminal = "kitty";
      show-lockscreen = true;
      show-power-options = true;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Yaru-dark";
    };

    "org/gnome/shell/extensions/space-bar/behavior" = {
      scroll-wheel = "disabled";
    };

    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      activate-empty-key = [ ];
      activate-previous-key = [ ];
      enable-activate-workspace-shortcuts = false;
      open-menu = [ ];
    };

    "org/gnome/shell/extensions/forge/keybindings" = {
      con-split-horizontal = [ ];
      con-split-layout-toggle = [ ];
      con-split-vertical = [ ];
      con-stacked-layout-toggle = [ ];
      con-tabbed-layout-toggle = [ ];
      con-tabbed-showtab-decoration-toggle = [ ];
      focus-border-toggle = [ ];
      mod-mask-mouse-tile = "None";
      prefs-open = [ ];
      prefs-tiling-toggle = [ ];
      window-focus-down = [ ];
      window-focus-left = [ ];
      window-focus-right = [ ];
      window-focus-up = [ ];
      window-gap-size-decrease = [ ];
      window-gap-size-increase = [ ];
      window-move-down = [ ];
      window-move-left = [ ];
      window-move-right = [ ];
      window-move-up = [ ];
      window-snap-center = [ ];
      window-snap-one-third-left = [ ];
      window-snap-one-third-right = [ ];
      window-snap-two-third-left = [ ];
      window-snap-two-third-right = [ ];
      window-swap-down = [ ];
      window-swap-last-active = [ ];
      window-swap-left = [ ];
      window-swap-right = [ ];
      window-swap-up = [ ];
      window-toggle-always-float = [ ];
      window-toggle-float = [ ];
      workspace-active-tile-toggle = [ ];
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      color-and-noise = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = true;
      style-dialogs = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = false;
      customize = false;
      whitelist = [ ];
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      override-background = false;
      style-dash-to-dock = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {

      blur = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {

      blur = true;
      style-components = 1;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
      override-background = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      blur = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      blur = false;
    };

    "org/gnome/shell/keybindings" = {
      focus-active-notification = [ ];
      open-application-menu = [ ];
      screenshot = [ ];
      screenshot-window = [ ];
      show-screen-recording-ui = [ ];
      show-screenshot-ui = [ ];
      toggle-application-view = [ ];
      toggle-message-tray = [ ];
      toggle-overview = [ "<Super>f" ];
    };

    "org/gnome/system/location" = {
      enabled = true;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };
  };
}
