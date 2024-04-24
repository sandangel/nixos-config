{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";

    nixGL.url = "github:nix-community/nixGL";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = "github:nix-community/neovim-nightly-overlay";

    # For rust nightly
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      home-manager,
      neovim,
      devenv,
      nixGL,
      fenix,
      ...
    }:
    let

      linux-user = "sand";
      mac-user = "san.nguyen";
      nix-conf =
        { user, pkgs }:
        {
          nix.settings.extra-trusted-users = [ user ];
          nix.settings.extra-trusted-public-keys = [
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
          nix.settings.extra-trusted-substituters = [ "https://devenv.cachix.org" ];
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      {
        systems = [ "aarch64-linux" ];
        debug = true;

        imports = [ inputs.devenv.flakeModule ];

        perSystem =
          {
            config,
            self',
            inputs',
            pkgs,
            system,
            lib,
            devenv,
            ...
          }:
          {
            devenv.shells.default = {
              languages.nix.enable = true;
            };
          };

        flake.overlays.default =
          final: prev: with prev; {
            neovim-nightly = neovim.packages.${final.stdenv.system}.neovim;
            kubeswitch = kubeswitch.overrideAttrs (o: rec {
              postInstall = ''
                mv $out/bin/main $out/bin/switcher
              '';
            });
            comic-code = callPackage ./pkgs/comic-code { };
            nvchad = callPackage ./pkgs/nvchad { };
            devenv = devenv.packages.${final.stdenv.system}.default;
          };

        flake.overlays.linux =
          final: prev: with prev; {
            nixGL = nixGL.packages.${final.stdenv.system}.default;
          };

        flake.homeConfigurations.${linux-user} = withSystem "aarch64-linux" (
          { system, config, ... }:
          home-manager.lib.homeManagerConfiguration rec {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                self.overlays.default
                self.overlays.linux
                fenix.overlays.default
              ];
            };
            extraSpecialArgs = {
              username = linux-user;
            };
            modules = [
              # Pin nixpkgs version in registry to speed up nix search and other functionalities
              (nix-conf {
                inherit pkgs;
                user = linux-user;
              })
              ./users/${linux-user}/home.nix
              inputs.nix.homeManagerModules.default
            ];
          }
        );

        flake.homeConfigurations.${mac-user} = withSystem "aarch64-darwin" (
          { system, config, ... }:
          home-manager.lib.homeManagerConfiguration rec {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                self.overlays.default
                fenix.overlays.default
              ];
            };
            extraSpecialArgs = {
              username = mac-user;
            };
            modules = [
              # Pin nixpkgs version in registry to speed up nix search and other functionalities
              (nix-conf {
                inherit pkgs;
                user = mac-user;
              })
              ./users/${mac-user}/home.nix
              inputs.nix.homeManagerModules.default
            ];
          }
        );
      }
    );
}
