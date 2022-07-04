{
  description = "NixOS systems and tools by sandangel";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    lib.url = "github:nix-community/lib-aggregate";

    home-manager = {
      url = "github:nix-community/home-manager";
      # We want home-manager to use the latest nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Other packages
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, home-manager, lib, ... }@inputs:
    let
      system = "aarch64-linux";
      username = "sand";
      machine = "vm-aarch64-prl";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [
          (final: prev: {
            inherit comic-code;
          })
        ];
      };
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.neovim-nightly-overlay.overlay
          (final: prev: {
            inherit pinniped kubeswitch;
          })
        ];
      };
      pinniped = with pkgs; buildGoModule rec {
        pname = "pinniped";
        version = "0.18.0";
        src = fetchFromGitHub {
          owner = "vmware-tanzu";
          repo = "pinniped";
          rev = "v${version}";
          sha256 = "sha256-S3JTxHeZ0QrhtakIaTOoQGU08qwjva8qcu2Bef+kMrA=";
        };
        subPackages = [ "cmd/pinniped" ];
        vendorSha256 = "sha256-V36b6x+wz5MeJzp/GPhX2sPATosOMEqGkeQdz4RbiEQ=";
      };
      kubeswitch = with pkgs; buildGoModule rec {
        pname = "kubeswitch";
        version = "0.7.1";
        src = fetchFromGitHub {
          owner = "danielfoehrKn";
          repo = "kubeswitch";
          rev = "${version}";
          sha256 = "sha256-IV21VvvjnhTMSYDpRflkqXfbKYPgNeIC/igBoXVwVLo=";
        };
        subPackages = [ "cmd" ];
        vendorSha256 = null;
        postInstall = ''
          mv $out/bin/cmd $out/bin/switcher
          cp -r $src/hack $out/
          cp -r $src/scripts $out/
        '';
      };
      comic-code = with pkgs; stdenvNoCC.mkDerivation {
        name = "comic-code";
        version = "0.1.0";
        src = /nix-config/pkgs/comic-code/comic-code.tar.gz;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          mkdir -p $out/share/fonts/opentype
          install -m444 -Dt $out/share/fonts/truetype ./*.ttf
          install -m444 -Dt $out/share/fonts/opentype ./*.otf
        '';
        meta = { description = "A Comic Code Font Family derivation with Nerd font."; };
      };
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit pkgs-unstable username; };
        modules = [
          ./users/${username}/home.nix
        ];
      };
      nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem rec {
        inherit system pkgs;
        modules = [
          (./. + "/hardware/${machine}.nix")
          (./. + "/machines/${machine}.nix")
          {
            environment.pathsToLink = [ "/share/fish" "/share/bash" "/share/zsh" ];
            users.users.${username} = {
              isNormalUser = true;
              isSystemUser = false;
              home = "/home/${username}";
              extraGroups = [ "docker" "wheel" ];
              shell = pkgs-unstable.zsh;
              initialPassword = username;
              useDefaultShell = false;
            };
            users.users.root.initialPassword = "root";
          }
        ];
      };
    } //
    lib.lib.flake-utils.eachSystem [ system ]
      (system: {
        devShells.default = with pkgs; mkShell {
          packages = [
            sumneko-lua-language-server
          ];
        };
      });
}
