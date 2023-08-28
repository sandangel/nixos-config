{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    devenv.url = "github:cachix/devenv";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = "github:nix-community/neovim-nightly-overlay";
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
        };
        packages = with pkgs; {
          neovim-nightly = neovim.packages.${system}.neovim;
          vcluster = callPackage ./pkgs/vcluster { };
          kubeswitch = callPackage ./pkgs/kubeswitch { };
          comic-code = callPackage ./pkgs/comic-code { };
        };
      };

      flake.homeConfigurations.${username} = withSystem "aarch64-linux" ({ system, config, ... }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (_: prev: with prev; {
                inherit (config.packages) neovim-nightly vcluster kubeswitch comic-code;
              })
            ];
          };
          extraSpecialArgs =
            let
              inherit (inputs.nixpkgs) lib;
              colorlib = import ./lib/colors.nix lib;
              default = import ./lib/theme { inherit colorlib lib; };
            in
            { inherit username default; };
          modules = [
            ./users/${username}/home.nix
          ];
        });
    });
}
