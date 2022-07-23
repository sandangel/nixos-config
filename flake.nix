{
  description = "NixOS systems and tools by sandangel";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    lib.url = "github:nix-community/lib-aggregate";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mach-nix.url = "mach-nix/3.5.0";
    mach-nix.inputs.nixpkgs.follows = "nixpkgs";

    neovim.url = "github:neovim/neovim?dir=contrib";
    neovim.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, neovim, home-manager, lib, ... }@inputs:
    let
      system = "aarch64-linux";
      username = "sand";
      machine = "vm-aarch64-prl";
      mach-nix = import inputs.mach-nix { python = "python310"; inherit pkgs; };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [
          (final: prev: {
            inherit comic-code pinniped kubeswitch neovim-nightly;
          })
        ];
      };
      neovim-nightly = neovim.packages.${system}.neovim;
      pinniped = with pkgs; buildGoModule rec {
        pname = "pinniped";
        version = "0.18.0";
        src = builtins.fetchGit {
          url = "https://github.com/vmware-tanzu/pinniped";
          ref = "refs/tags/v${version}";
        };
        subPackages = [ "cmd/pinniped" ];
        vendorSha256 = "sha256-V36b6x+wz5MeJzp/GPhX2sPATosOMEqGkeQdz4RbiEQ=";
      };
      kubeswitch = with pkgs; buildGoModule rec {
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
        extraSpecialArgs = { inherit mach-nix username; };
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
              shell = pkgs.zsh;
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
