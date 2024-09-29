{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    binutils
    # glxinfo
    # xdg-utils

    bind
    # # Fix issue with error: "cannot allocate memory in static TLS block" when LD_AUDIT is set for packages depending on jemalloc
    # # https://github.com/flox/flox/issues/1341#issuecomment-2111136929
    # (bind.overrideAttrs (oldAttrs: {
    #   nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];
    #   postInstall =
    #     # All binaries can be found in nixpkgs
    #     # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/dns/bind/default.nix
    #     ''
    #       for binary in $out/bin/{host,dig,delv,nslookup,nsupdate}; do
    #         wrapProgram $binary --unset LD_AUDIT
    #       done
    #     ''
    #     # Output will be moved so need to wrapProgram first before oldAttrs.postInstall
    #     + oldAttrs.postInstall;
    # }))

    # To run GUI apps
    # nixGL

    # Fix static link .so
    # flox
  ];

  xdg.enable = true;

  # To source .desktop applications installed by home-manager
  # programs.bash.enable = true;
  # targets.genericLinux.enable = true;

  imports = [
    ../../modules/cloud
    ../../modules/direnv
    ../../modules/firefox
    ../../modules/git
    ../../modules/gnome
    # ../../modules/hyprland
    ../../modules/alacritty
    ../../modules/kitty
    ../../modules/ghostty
    ../../modules/kubernetes
    ../../modules/misc
    ../../modules/nvim
    ../../modules/zsh
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";

    # Override MESA version since UTM QEMU some how populate the version
    # to be 2.1, which does not meet the requirement of Kitty
    # https://github.com/utmapp/UTM/issues/6454#issuecomment-2204562856
    # This is needed for QEMU in UTM
    # MESA_GL_VERSION_OVERRIDE = "4.3";
    # MESA_GLSL_VERSION_OVERRIDE = "430";
    # MESA_GLES_VERSION_OVERRIDE = "3.1";

    # Fix static links in nixpkgs
    # LD_AUDIT = "${pkgs.ld-floxlib}/lib/ld-floxlib.so";
  };

  home.stateVersion = "24.05";
}
