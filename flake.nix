{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
        };
        overlayAttrs = {
          inherit (config.packages) neovim-nightly vcluster kubeswitch comic-code flypie;
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

      flake.homeConfigurations.${username} = withSystem "aarch64-linux" ({ final, ... }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = final;
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
