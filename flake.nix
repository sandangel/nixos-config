{
  inputs = {
    # Mirroring nixpkgs unstable
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    # Updating nix itself
    nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";

    # For running GUI apps
    nixGL.url = "github:nix-community/nixGL";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";

    # Fix static linking issues
    # flox.url = "github:flox/flox";
    # ld-floxlib.url = "github:flox/ld-floxlib";

    # Should follow nixpkgs for home-manager packages
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Do not follow nixpkgs so it can be built reliably
    neovim.url = "github:nix-community/neovim-nightly-overlay";

    # For rust nightly
    # fenix.url = "github:nix-community/fenix";
    # fenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      neovim,
      devenv,
      # flox,
      # ld-floxlib,
      nixGL,
      # fenix,
      ...
    }:
    let

      linux-user = "sand";
      mac-user = "san.nguyen";
      modules =
        { user }:
        [
          {
            nix.settings.extra-trusted-users = [ user ];
            nix.settings.extra-trusted-public-keys = [
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
              "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
            ];
            nix.settings.extra-trusted-substituters = [
              "https://devenv.cachix.org"
              "https://cache.flox.dev"
            ];
          }
          ./users/${user}/home.nix
          inputs.nix.homeManagerModules.default
        ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      {
        systems = [ "aarch64-linux" ];
        debug = true;

        imports = [ inputs.devenv.flakeModule ];

        perSystem =
          { ... }:
          {
            devenv.shells.default = {
              languages.nix.enable = true;
            };
          };

        flake.overlays.default = final: prev: {
          neovim-nightly = neovim.packages.${final.stdenv.system}.neovim;
          kubeswitch = prev.kubeswitch.overrideAttrs (o: {
            postInstall = ''
              mv $out/bin/main $out/bin/switcher
            '';
          });
          comic-code = prev.callPackage ./pkgs/comic-code { };
          nvchad = prev.callPackage ./pkgs/nvchad { };
          devenv = devenv.packages.${final.stdenv.system}.default;
          # flox = flox.packages.${final.stdenv.system}.default;
        };

        flake.overlays.linux = final: prev: {
          nixGL = nixGL.packages.${final.stdenv.system}.default;
          # ld-floxlib = ld-floxlib.packages.${final.stdenv.system}.ld-floxlib;
        };

        flake.homeConfigurations.${linux-user} = withSystem "aarch64-linux" (
          { system, ... }:
          home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                self.overlays.default
                self.overlays.linux
                # fenix.overlays.default
              ];
            };
            extraSpecialArgs = {
              username = linux-user;
            };
            modules = modules { user = linux-user; };
          }
        );

        flake.homeConfigurations.${mac-user} = withSystem "aarch64-darwin" (
          { system, ... }:
          home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                self.overlays.default
                # fenix.overlays.default
              ];
            };
            extraSpecialArgs = {
              username = mac-user;
            };
            modules = modules { user = mac-user; };
          }
        );
      }
    );
}
