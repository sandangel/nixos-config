{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

    devenv.url = "github:cachix/devenv";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = "github:nix-community/neovim-nightly-overlay";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprpaper.url = "github:hyprwm/hyprpaper";

    fufexan.url = "github:fufexan/dotfiles";
  };
  outputs = inputs@{ flake-parts, nixpkgs, home-manager, hyprland, hyprpaper, neovim, fufexan, devenv, ... }:
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
          hyprpaper = hyprpaper.packages.${system}.hyprpaper;
          vcluster = callPackage ./pkgs/vcluster { };
          kubeswitch = callPackage ./pkgs/kubeswitch { };
          comic-code = callPackage ./pkgs/comic-code { };
          flypie = callPackage ./pkgs/flypie { };
          mesa = (callPackage
            (import ./pkgs/mesa/generic.nix {
              version = "23.1.3";
              hash = "sha256-L21zgbwQ+9LWJjrRAieFuLURBGwakEFi+PfaGO6ortk=";
            })
            {
              inherit (darwin.apple_sdk_11_0.frameworks) OpenGL;
              inherit (darwin.apple_sdk_11_0.libs) Xplugin;
            }).override {
            galliumDrivers = [
              "swrast" # software renderer (aka LLVMPipe)
              "svga" # VMWare virtualized GPU
            ];
            vulkanDrivers = [ ];
            vulkanLayers = [ ];
          };
        };
        overlayAttrs = {
          inherit (config.packages) neovim-nightly vcluster kubeswitch comic-code flypie mesa;
        };
      };

      flake.nixosConfigurations = withSystem "aarch64-linux" ({ system, final, ... }:
        let
          mkMachine = machine: nixpkgs.lib.nixosSystem rec {
            pkgs = final;
            modules = [
              { nixpkgs.hostPlatform = system; }
              { _module.args = { inherit machine username; }; }
              hyprland.nixosModules.default
              { programs.hyprland.enable = false; }
              (./. + "/hardware/${machine}.nix")
              (./. + "/machines/${machine}.nix")
              {
                programs.zsh.enable = true;
                users.users.${username} = {
                  isNormalUser = true;
                  isSystemUser = false;
                  home = "/home/${username}";
                  extraGroups = [ "docker" "wheel" "video" ];
                  shell = final.zsh;
                  initialPassword = username;
                  useDefaultShell = false;
                };
                users.users.root.initialPassword = "root";
              }
            ];
          };
        in
        {
          vm-aarch64-prl = mkMachine "vm-aarch64-prl";
          vm-aarch64 = mkMachine "vm-aarch64";
        });

      flake.homeConfigurations.${username} = withSystem "aarch64-linux" ({ final, system, ... }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (_: prev: with prev; {
                inherit (final) neovim-nightly vcluster kubeswitch comic-code flypie mesa;
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
            hyprland.homeManagerModules.default
            fufexan.homeManagerModules.eww-hyprland
            ./users/${username}/home.nix
          ];
        });
    });
}
