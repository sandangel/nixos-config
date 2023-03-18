{
  description = "NixOS systems and tools by sandangel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim.url = "github:neovim/neovim?dir=contrib";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, neovim, home-manager, devenv, ... }@inputs:
    let
      system = "aarch64-linux";
      username = "sand";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [
          (final: prev: with prev; {
            devenv = devenv.packages.${system}.devenv;
            neovim-nightly = neovim.packages.${system}.neovim;
            vcluster = stdenvNoCC.mkDerivation rec {
              pname = "vcluster";
              version = "0.14.2";
              src = fetchurl {
                url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-${if stdenv.isAarch64 then "linux-arm64" else "linux-amd64"}";
                sha256 = if system == "aarch64-linux" then "sha256-dpIqzKGvsh9/60Rcg4weEZkVWGfa8ipUh+P4qrIaAhQ=" else lib.fakeSha256;
              };
              nativeBuildInputs = [ installShellFiles ];
              phases = [ "installPhase" "postInstall" ];
              installPhase = ''
                mkdir -p $out/bin
                install -Dm755 $src -T $out/bin/vcluster
                runHook postInstall
              '';
              postInstall = ''
                installShellCompletion --cmd vcluster \
                  --bash <($out/bin/vcluster completion bash) \
                  --zsh <($out/bin/vcluster completion zsh)
              '';
              meta = with lib; {
                description = "Create fully functional virtual Kubernetes clusters";
                downloadPage = "https://github.com/loft-sh/vcluster";
                homepage = "https://www.vcluster.com/";
                license = licenses.asl20;
              };
            };
            kubeswitch = buildGoModule rec {
              pname = "kubeswitch";
              version = "0.7.2";
              src = builtins.fetchGit {
                url = "https://github.com/danielfoehrKn/kubeswitch";
                ref = "refs/tags/${version}";
              };
              subPackages = [ "cmd" ];
              vendorSha256 = null;
              postInstall = ''
                mv $out/bin/cmd $out/bin/switcher
                cp -r $src/hack $out/
                cp -r $src/scripts $out/
              '';
            };
            yamlfmt = stdenvNoCC.mkDerivation rec {
              pname = "yamlfmt";
              version = "0.7.1";
              src = fetchzip {
                url = "https://github.com/google/yamlfmt/releases/download/v${version}/yamlfmt_${version}_Linux_arm64.tar.gz";
                # sha256 = lib.fakeSha256;
                sha256 = "sha256-GHsG4xv/pqRgc9NwNWBvLv8larjk8BigDn6MGlNwC48=";
                stripRoot = false;
              };
              phases = [ "installPhase" ];
              installPhase = ''
                mkdir -p $out/bin
                install -Dm755 $src/yamlfmt -T $out/bin/yamlfmt
              '';
            };
            comic-code = stdenvNoCC.mkDerivation {
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
          })
        ];
      };
      mkMachine = machine: nixpkgs.lib.nixosSystem rec {
        inherit system pkgs;
        modules = [
          { _module.args = { inherit machine username; }; }
          (./. + "/hardware/${machine}.nix")
          (./. + "/machines/${machine}.nix")
          {
            environment.pathsToLink = [ "/share/fish" "/share/bash" "/share/zsh" ];
            users.users.${username} = {
              isNormalUser = true;
              isSystemUser = false;
              home = "/home/${username}";
              extraGroups = [ "docker" "wheel" ];
              shell = pkgs.zsh;
              initialPassword = username;
              useDefaultShell = false;
            };
            users.users.root.initialPassword = "root";
          }
        ];
      };
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit username; };
        modules = [
          ./users/${username}/home.nix
        ];
      };
      nixosConfigurations."vm-aarch64-prl" = mkMachine "vm-aarch64-prl";
      nixosConfigurations."vm-aarch64" = mkMachine "vm-aarch64";
    };
}
