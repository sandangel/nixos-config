{
  inputs = {
    # Mirroring nixpkgs unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ghostty.url = "github:ghostty-org/ghostty";
    # ghostty.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # For running GUI apps
    # nixGL.url = "github:nix-community/nixGL";
    # nixGL.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

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

    # For rust nightly toolchain (blink.cmp build)
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      nixpkgs,
      determinate,
      dms,
      # ghostty,
      niri,
      disko,
      nix-flatpak,
      # neovim,
      # devenv,
      # flox,
      # ld-floxlib,
      # nixGL,
      fenix,
      ...
    }:
    let

      linux-user = "sand";
      mac-user = "san.nguyen";
      nix-options = {
        nix = {
          registry.nixpkgs.flake = nixpkgs;
          settings = {
            auto-optimise-store = true;
            warn-dirty = false;
          };
          gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than +5";
          };
        };
      };
      modules =
        { user }:
        [
          {
            nix.settings = {
              extra-trusted-users = [ user ];
              extra-trusted-public-keys = [
                "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
                "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
                "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
              ];
              extra-trusted-substituters = [
                "https://devenv.cachix.org"
                "https://cache.flox.dev"
                "https://ghostty.cachix.org"
              ];
            };
          }
          ./users/${user}/home.nix
        ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      {
        systems = [ "aarch64-linux" ];
        debug = true;

        imports = [ inputs.devenv.flakeModule ];

        perSystem =
          _:
          {
            devenv.shells.default = {
              # languages.nix.enable = true;
            };
            # packages.default = ghostty.packages.${system}.ghostty;
          };

        flake = {
          overlays.default = final: prev: {
            # neovim-nightly = neovim.packages.${final.stdenv.system}.neovim;
            # comic-code = prev.callPackage ./pkgs/comic-code { };
            # nvchad = prev.callPackage ./pkgs/nvchad { };
            # devenv = devenv.packages.${final.stdenv.system}.default;
            # flox = flox.packages.${final.stdenv.system}.default;
            # ghostty = ghostty.packages.${final.stdenv.system}.ghostty;
          };

          overlays.linux = final: prev: {
            # nixGL = nixGL.packages.${final.stdenv.system}.default;
            # ld-floxlib = ld-floxlib.packages.${final.stdenv.system}.ld-floxlib;
          };

          nixosConfigurations.parallels-desktop = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              ./machines/parallels/configuration.nix
              disko.nixosModules.disko
              niri.nixosModules.niri
              determinate.nixosModules.default
              nix-flatpak.nixosModules.nix-flatpak
              nix-options
              ./machines/parallels/disko-config.nix
              ./machines/common.nix
              dms.nixosModules.dank-material-shell
              {
                nixpkgs.overlays = [
                  self.overlays.default
                  self.overlays.linux
                  fenix.overlays.default
                  niri.overlays.niri
                ];
                nixpkgs.config.permittedInsecurePackages = [
                  "beekeeper-studio-5.5.7"
                ];
              }
              {
                disko.devices.disk.primary.device = "/dev/sda";
                disko.devices.disk.secondary.device = "/dev/sdb";
                environment.systemPackages = [
                  # ghostty.packages.${system}.ghostty
                  # nixGL.packages.${system}.default
                ];
              }
              home-manager.nixosModules.home-manager
            ];
          };

          nixosConfigurations.vmware-fusion = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ./machines/vmware-fusion/configuration.nix
              disko.nixosModules.disko
              ./machines/vmware-fusion/disko-config.nix
              ./machines/common.nix
              {
                disko.devices.disk.main.device = "/dev/nvme0n3";
                disko.devices.disk.home.device = "/dev/nvme0n4";
                environment.systemPackages = [
                  # ghostty.packages.${system}.ghostty
                  # nixGL.packages.${system}.default
                ];
              }
              home-manager.nixosModules.home-manager
            ];
          };

          homeConfigurations.${linux-user} = withSystem "aarch64-linux" (
            { system, ... }:
            home-manager.lib.homeManagerConfiguration {
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
                inherit inputs;
                username = linux-user;
              };
              modules = modules { user = linux-user; };
            }
          );

          homeConfigurations.${mac-user} = withSystem "aarch64-darwin" (
            { system, ... }:
            home-manager.lib.homeManagerConfiguration {
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
              modules = modules { user = mac-user; };
            }
          );
        };
      }
    );
}
