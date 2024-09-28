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
  programs.bash.enable = true;
  targets.genericLinux.enable = true;

  imports = [
    ../../modules/cloud
    ../../modules/direnv
    ../../modules/firefox
    ../../modules/git
    ../../modules/gnome
    ../../modules/hyprland
    ../../modules/kitty
    ../../modules/ghostty
    ../../modules/kubernetes
    ../../modules/misc
    ../../modules/nvim
    ../../modules/zsh
  ];

  systemd.user.services = {
    home-manager-update = {
      Unit = {
        Description = "Update packages managed by home-manager.";
      };
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "home-manager-update-sh" ''
            set -eou pipefail
            cd /home/${username}/.nix-config
            /nix/var/nix/profiles/default/bin/nix flake update
            /usr/bin/make switch
          ''
        );
      };
    };
  };

  systemd.user.timers = {
    home-manager-update = {
      Unit.Description = "Timer for home-manager-update service.";
      Timer = {
        Unit = "home-manager-update.service";
        OnCalendar = "Sun *-*-* 05:00:00"; # Weekly on Sunday
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";

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
}
