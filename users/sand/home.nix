{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    binutils
    glxinfo
    xdg-utils
    # Fix issue with error: "cannot allocate memory in static TLS block" when LD_AUDIT is set for packages depending on jemalloc
    # https://github.com/flox/flox/issues/1341#issuecomment-2111136929
    (bind.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];
      postInstall =
        # All binaries can be found in nixpkgs
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/dns/bind/default.nix
        ''
          for binary in $out/bin/{host,dig,delv,nslookup,nsupdate}; do
            wrapProgram $binary --unset LD_AUDIT
          done
        ''
        # Output will be moved so need to wrapProgram first before oldAttrs.postInstall
        + oldAttrs.postInstall;
    }))

    # To run GUI apps
    nixGL
  ];

  xdg.enable = true;

  # To source .desktop applications installed by home-manager
  programs.bash.enable = true;
  targets.genericLinux.enable = true;

  imports = [
    ../../modules/cloud
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
