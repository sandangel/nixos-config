{ pkgs, lib, config, username, ... }:

{
  home.stateVersion = "22.05";
  home.packages = with pkgs; [
    azure-cli
    bind
    binutils
    cachix
    comic-code
    gh
    git
    glib
    gnumake
    killall
    nerdfonts
    nurl
    ssm-session-manager-plugin
    vim
    xdg-utils

    fenix.stable.toolchain

    (rye.overrideAttrs (o: rec {
      version = "0.30.0";
      src = fetchFromGitHub {
        owner = "astral-sh";
        repo = "rye";
        rev = "refs/tags/${version}";
        hash = "sha256-a4u8dBqp9zs4RW7tXN8HjGzvjYFyDUJzEFMxMoGhu4E=";
      };
      # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md#vendoring-of-dependencies-vendoring-of-dependencies
      cargoDeps = rustPlatform.importCargoLock {
        lockFile = "${src}/Cargo.lock";
        outputHashes = {
          "dialoguer-0.10.4" = "sha256-WDqUKOu7Y0HElpPxf2T8EpzAY3mY8sSn9lf0V0jyAFc=";
          "monotrail-utils-0.0.1" = "sha256-ydNdg6VI+Z5wXe2bEzRtavw0rsrcJkdsJ5DvXhbaDE4=";
        };
      };
      doCheck = false;
    }))

    (hatch.overrideAttrs (_: rec {
      version = "1.9.3";
      src = fetchPypi {
        pname = "hatch";
        inherit version;
        hash = "sha256-ZyAX40nFSPipV6X+6aovjPwsiplDBzeORahCeXK9+Nk=";
      };
      # pytest is failing because of sandbox environment
      pytestCheckPhase = "echo true";
    }))
  ];

  home.sessionVariables = with pkgs; rec {
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

  programs.eza.enable = true;
  programs.eza.icons = true;
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
