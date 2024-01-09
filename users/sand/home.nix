{ pkgs, lib, config, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    bind
    binutils
    cachix
    glib
    glxinfo
    killall
    perl
    postgresql
    wl-clipboard
    xclip
    xdg-utils

    # To run GUI apps
    nixGL
  ];

  xdg.enable = true;

  # To source .desktop applications installed by home-manager
  programs.bash.enable = true;
  targets.genericLinux.enable = true;

  imports = [
    ../../modules/direnv
    ../../modules/git
    ../../modules/gnome
    ../../modules/kitty
    ../../modules/kubernetes
    ../../modules/misc
    ../../modules/nvim
    ../../modules/zsh
  ];

  xdg.desktopEntries.kitty = {
    name = "kitty";
    genericName = "Terminal emulator";
    exec = "${pkgs.nixGL}/bin/nixGL ${pkgs.kitty}/bin/kitty --start-as=maximized";
    icon = "kitty";
    comment = "Fast, feature-rich, GPU based terminal";
    categories = [ "System" "TerminalEmulator" ];
  };

  xdg.configFile."autostart/kitty.desktop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-profile/share/applications/kitty.desktop";

  home.sessionVariables = with pkgs; rec {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    MANPAGER = "sh -c 'col -bx | commnand bat -l man -p'";
    PAGER = "less -FirSwX";

    GDK_SCALE = "2";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
