{
  description = "NixOS systems and tools by sandangel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim.url = "github:neovim/neovim?dir=contrib";
    neovim.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, neovim, home-manager, ... }@inputs:
    let
      system = "aarch64-linux";
      username = "sand";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [
          (final: prev: {
            neovim-nightly = neovim.packages.${system}.neovim;
            pinniped = prev.buildGoModule rec {
              pname = "pinniped";
              version = "0.20.0";
              src = builtins.fetchGit {
                url = "https://github.com/vmware-tanzu/pinniped";
                ref = "refs/tags/v${version}";
              };
              subPackages = [ "cmd/pinniped" ];
              vendorSha256 = "sha256-szv/B7LG/In0j6MT6KCnuUfaCnK7RsJOLeuOtJ/ig9w=";
            };
            kubeswitch = prev.buildGoModule rec {
              pname = "kubeswitch";
              version = "0.7.1";
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
            comic-code = prev.stdenvNoCC.mkDerivation {
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
          { _module.args = { inherit machine; }; }
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
