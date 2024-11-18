{
  inputs = {
    # Mirroring nixpkgs unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    ghostty.url = "git+ssh://git@github.com/ghostty-org/ghostty";
    ghostty.inputs.nixpkgs-stable.follows = "nixpkgs";
    ghostty.inputs.nixpkgs-unstable.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Updating nix itself
    nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";

    # For running GUI apps
    # nixGL.url = "github:nix-community/nixGL";
    # nixGL.inputs.nixpkgs.follows = "nixpkgs";

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
    # neovim.url = "github:nix-community/neovim-nightly-overlay";

    # For rust nightly
    # fenix.url = "github:nix-community/fenix";
    # fenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      nixpkgs,
      ghostty,
      disko,
      # neovim,
      # devenv,
      # flox,
      # ld-floxlib,
      # nixGL,
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
          # neovim-nightly = neovim.packages.${final.stdenv.system}.neovim;
          # comic-code = prev.callPackage ./pkgs/comic-code { };
          # nvchad = prev.callPackage ./pkgs/nvchad { };
          # devenv = devenv.packages.${final.stdenv.system}.default;
          # flox = flox.packages.${final.stdenv.system}.default;
          # ghostty = ghostty.packages.${final.stdenv.system}.ghostty;
        };

        flake.overlays.linux = final: prev: {
          # nixGL = nixGL.packages.${final.stdenv.system}.default;
          # ld-floxlib = ld-floxlib.packages.${final.stdenv.system}.ld-floxlib;
        };

        flake.nixosConfigurations.parallels-desktop = nixpkgs.lib.nixosSystem rec {
          system = "aarch64-linux";
          modules = [
            ./machines/parallels/configuration.nix
            disko.nixosModules.disko
            ./machines/parallels/disko-config.nix
            ./machines/common.nix
            {
              disko.devices.disk.main.device = "/dev/sdc";
              disko.devices.disk.work.device = "/dev/sdb";
              environment.systemPackages = [
                ghostty.packages.${system}.ghostty
                # nixGL.packages.${system}.default
              ];
            }
            home-manager.nixosModules.home-manager
          ];
        };
        flake.nixosConfigurations.vmware-fusion = nixpkgs.lib.nixosSystem rec {
          system = "aarch64-linux";
          modules = [
            ./machines/vmware-fusion/configuration.nix
            disko.nixosModules.disko
            ./machines/vmware-fusion/disko-config.nix
            ./machines/common.nix
            {
              disko.devices.disk.main.device = "/dev/nvme0n3";
              disko.devices.disk.work.device = "/dev/nvme0n4";
              environment.systemPackages = [
                ghostty.packages.${system}.ghostty
                # nixGL.packages.${system}.default
              ];
            }
            home-manager.nixosModules.home-manager
          ];
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
