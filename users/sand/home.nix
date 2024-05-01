{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    binutils
    glxinfo
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

  home.sessionVariables = {
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
    MOZ_USE_XINPUT2 = 1;
    CHROMIUM_USER_FLAGS = "--force-device-scale-factor=2";

    # Fix static links in nixpkgs
    LD_AUDIT = "${pkgs.ld-floxlib}/lib/ld-floxlib.so";
  };
}
