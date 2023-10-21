{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  outputs = inputs@{ flake-parts, nixpkgs, home-manager, neovim, devenv, ... }:
    let
      username = "sand";
    in
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = [ "aarch64-linux" ];
      debug = true;

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.devenv.flakeModule
      ];

      perSystem = { config, self', inputs', pkgs, system, lib, devenv, ... }: {
        devenv.shells.default = {
          languages.nix.enable = true;
          languages.javascript.enable = true;
          languages.go.enable = true;
          languages.rust = {
            enable = true;
            channel = "nightly";
            components = [ "rustc" "cargo" "clippy" "rustfmt" ];
          };
        };
        packages = with pkgs; {
          neovim-nightly = neovim.packages.${system}.neovim;
          kubeswitch = kubeswitch.overrideAttrs (o: rec {
            postInstall = ''
              mv $out/bin/main $out/bin/switcher
            '';
          });
          comic-code = callPackage ./pkgs/comic-code { };
          nvchad = callPackage ./pkgs/nvchad { };
        };
      };

      flake.homeConfigurations.${username} = withSystem "aarch64-linux" ({ system, config, ... }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (_: prev: with prev; {
                inherit (config.packages) neovim-nightly kubeswitch comic-code nvchad;
              })
            ];
          };
          extraSpecialArgs = { inherit username; };
          modules = [
            ./users/${username}/home.nix
          ];
        });
    });
}
