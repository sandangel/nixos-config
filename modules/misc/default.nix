{ pkgs, ... }:
{
  # home.stateVersion = "22.05";
  home.packages = (
    with pkgs;
    [
      # Utilities
      # glib
      # gnumake
      # killall
      # vim
      # binutils
      # bind

      # Fonts
      # comic-code
      # nerdfonts
      # nerd-fonts.jetbrains-mono

      # Nix
      nurl
      devenv
      cachix

      # Git
      gh
      # git

      # Rust toolchain
      # fenix.stable.toolchain
      # gcc

      # Image viewer
      # chafa

      # Python toolchain
      # rye
      # hatch
      uv

      # Web Dev
      bun

      # Tools
      (television.overrideAttrs (
        final: prev: rec {
          version = "0.13.3";
          src = fetchFromGitHub {
            owner = "alexpasmantier";
            repo = "television";
            tag = version;
            hash = "sha256-5keGAP6/C1kWjD+Wo+v6rFUll5y+uKGDFn3wN14IUuc=";
          };
          cargoDeps = prev.cargoDeps.overrideAttrs (oldAttrs: {
            vendorStaging = oldAttrs.vendorStaging.overrideAttrs {
              inherit (final) src;
              outputHash = "sha256-kb2v4uVQy7m3JVnazbtPjgYyal0mBu97X1ivg4L7wxg=";
            };
          });
        }
      ))

      # DB
      # beekeeper-studio
    ]
  );

  home.sessionVariables = rec {
    FZF_BIND_OPTS = "--bind page-up:preview-up,page-down:preview-down,?:toggle-preview";
    FZF_CTRL_T_COMMAND = "rg --files";
    FZF_CTRL_T_OPTS = "${FZF_PREVIEW_OPTS} ${FZF_BIND_OPTS}";
    FZF_DEFAULT_COMMAND = "rg --files";
    FZF_DEFAULT_OPTS = "--ansi --border ${FZF_BIND_OPTS}";
    FZF_PREVIEW_COMMAND = "bat {}";
    FZF_PREVIEW_OPTS = "--preview '${FZF_PREVIEW_COMMAND}'";
  };

  fonts.fontconfig.enable = true;

  programs.ripgrep.enable = true;
  programs.ripgrep.arguments = [
    "--follow"
    "--smart-case"
    "--hidden"
    "--glob=!.git/*"
    "--glob=!node_modules/*"
    "--glob=!*.lock"
    "--glob=!*-lock.json"
    "--glob=!*.min.{js,css}"
    "--glob=!*.lock.hcl"
    "--glob=!__snapshots__"
    "--glob=!dist"
  ];

  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.fd.enable = true;

  programs.vscode.enable = true;

  programs.eza.enable = true;
  programs.eza.icons = "auto";
  programs.eza.git = true;
  programs.eza.extraOptions = [
    "--group-directories-first"
    "--header"
  ];

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "TwoDark";
      style = "numbers,changes";
      color = "always";
    };
  };

  programs.info.enable = true;
  programs.nix-index.enable = true;
  programs.jq.enable = true;

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs.home-manager.enable = true;
}
