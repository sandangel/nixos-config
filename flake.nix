{
  description = "NixOS systems and tools by sandangel";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

    # Use this linux kernel so parallels-tools can work
    nixpkgs-21-11.url = "github:nixos/nixpkgs/release-21.11";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      # We want home-manager to use the latest nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Other packages
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    comic-code = {
      url = "path:./pkgs/comic-code";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "aarch64-linux";
    username = "sand";
    machine = "vm-aarch64-prl";
    pkgs-22-05 = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowUnsupportedSystem = true;
    };
    pkgs-21-11 = import inputs.nixpkgs-21-11 {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      config.allowUnsupportedSystem = true;
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
    };
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit system username pkgs;
      configuration = import ./users/${username}/home.nix;
      extraSpecialArgs = { inherit pkgs-22-05; };
      homeDirectory = "/home/${username}";
      stateVersion = "22.05";
    };
    nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem rec {
      inherit system;
      modules = [
        { config._module.args = { inherit pkgs-21-11; }; }
        {
          nixpkgs.overlays = [
            (final: prev: {
              comic-code = inputs.comic-code.packages.${prev.system}.comic-code;
              firefox = pkgs.firefox;
            })
          ];
        }
        ./hardware/${machine}.nix
        ./machines/${machine}.nix
        {
          environment.pathsToLink = [ "/share/fish" ];
          users.users.${username} = {
            isNormalUser = true;
            isSystemUser = false;
            home = "/home/${username}";
            extraGroups = [ "docker" "wheel" ];
            shell = pkgs.fish;
            initialPassword = username;
            useDefaultShell = false;
          };
        }
      ];
    };
    devShell.${system} = pkgs.mkShell {
      packages = with pkgs; [
        sumneko-lua-language-server
      ];
    };
  };
}
