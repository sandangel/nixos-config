{ pkgs, lib, ... }:
let
  fluent-icon-theme = pkgs.fluent-icon-theme.overrideAttrs (o: {
    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Fluent-icon-theme";
      rev = "53866de0b88132627d1301964a51e997edfd3391"; # 2024-05-19
      hash = "sha256-Mv5O2UGUfMgHZkeD3LD37Q0w8jM+j4yz26garhDUFGM=";
    };
  });
  fluent-gtk-theme = pkgs.fluent-gtk-theme.overrideAttrs (o: {
    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Fluent-gtk-theme";
      rev = "423fe6fad9a43dce32ea19f137533399ad6c7420"; # 2024-05-19
      hash = "sha256-0jlwJnqHnZrL6RshjSiHg1kiv+TRsc+2p1G7ze7/fy8=";
    };
  });
  gtk-theme = "Fluent-Dark";
  icon-theme = "Fluent-dark";
  picture-uri = "file:///var/home/nix-config/images/wall.png";
in
{
  home.file.".themes".source = "${fluent-gtk-theme}/share/themes";

  home.file.".icons".source = "${fluent-icon-theme}/share/icons";

  gtk = {
    enable = true;

    iconTheme = {
      name = icon-theme;
      package = fluent-icon-theme;
    };

    theme = {
      name = gtk-theme;
      package = fluent-gtk-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Note that the database is strongly-typed so you need to use the same types as described in the GSettings schema.
  dconf.settings = {
    "com/ftpix/transparentbar" = {
      dark-full-screen = false;
      transparency = 0;
    };

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      delay = lib.hm.gvariant.mkUint32 150;
      repeat-interval = lib.hm.gvariant.mkUint32 3;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
      speed = 1.0;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 0;
    };

    "org/gnome/GWeather4" = {
      temperature-unit = "centigrade";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = picture-uri;
      picture-uri-dark = picture-uri;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = picture-uri;
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
      enabled-extensions = with pkgs.gnomeExtensions; [
        blur-my-shell.extensionUuid
        forge.extensionUuid
        user-themes.extensionUuid
        transparent-top-bar-adjustable-transparency.extensionUuid
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "org.gnome.Extensions.desktop"
        "org.gnome.Settings.desktop"
        "kitty.desktop"
        "org.gnome.tweaks.desktop"
        "ca.desrt.dconf-editor.desktop"
        "org.gnome.Software.desktop"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = gtk-theme;
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
      window-resize-bottom-decrease = [ ];
      window-resize-bottom-increase = [ ];
      window-resize-left-decrease = [ ];
      window-resize-left-increase = [ ];
      window-resize-right-decrease = [ ];
      window-resize-right-increase = [ ];
      window-resize-top-decrease = [ ];
      window-resize-top-increase = [ ];
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      color-and-noise = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = true;
      style-dialogs = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      customize = false;
      whitelist = [
        "kitty"
        "neovide"
      ];
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
