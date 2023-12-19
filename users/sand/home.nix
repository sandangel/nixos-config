{ pkgs, lib, config, username, ... }:

{
  home.username = username;
  home.stateVersion = "22.05";
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    bind
    binutils
    cachix
    comic-code
    gh
    git
    glib
    glxinfo
    gnumake
    killall
    kubectl
    kubectx
    kubeswitch
    perl
    pinniped
    postgresql
    ssm-session-manager-plugin
    nerdfonts
    tree-sitter
    vcluster
    vim
    wl-clipboard
    xclip
    xdg-utils
    k9s

    # To run GUI apps
    nixGL
  ];

  xdg.enable = true;

  # To source .desktop applications installed by home-manager
  programs.bash.enable = true;
  targets.genericLinux.enable = true;

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;

  imports = [
    ./zsh
    # ./fish
    ./git
    ./kitty
    ./gnome
    ./nvim
  ];

  home.sessionVariables = with pkgs; rec {
    FZF_BIND_OPTS = "--bind page-up:preview-up,page-down:preview-down,?:toggle-preview";
    FZF_CTRL_T_COMMAND = "rg --files";
    FZF_CTRL_T_OPTS = "${FZF_PREVIEW_OPTS} ${FZF_BIND_OPTS}";
    FZF_DEFAULT_COMMAND = "rg --files";
    FZF_DEFAULT_OPTS = "--ansi --border ${FZF_BIND_OPTS}";
    FZF_PREVIEW_COMMAND = "bat {}";
    FZF_PREVIEW_OPTS = "--preview '${FZF_PREVIEW_COMMAND}'";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    MANPAGER = "sh -c 'col -bx | commnand bat -l man -p'";
    PAGER = "less -FirSwX";

    GDK_SCALE = "2";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
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
  programs.eza.enableAliases = true;
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
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.stdlib = ''
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    declare -A direnv_layout_dirs
    direnv_layout_dir() {
        local hash path
        echo "''${direnv_layout_dirs[$PWD]:=$(
            hash="$(sha1sum - <<< "$PWD" | head -c40)"
            path="''${PWD//[^a-zA-Z0-9]/}"
            echo "$XDG_CACHE_HOME/direnv/layouts/$hash-$path"
        )}"
    }

    use_flake() {
      watch_file flake.nix
      watch_file flake.lock
      eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
    }

    layout_poetry() {
      if has poetry; then
        if [[ ! -f pyproject.toml ]]; then
          echo 'No pyproject.toml found. Use `poetry init` to create one first.'
          poetry init
        fi

        # create venv if it doesn't exist
        poetry run true

        export VIRTUAL_ENV=$(poetry env info --path)
        export POETRY_ACTIVE=1
        PATH_add "$VIRTUAL_ENV/bin"
      fi
    }

    layout_pdm() {
      if has pdm; then
        # create venv if it doesn't exist
        if [[ ! -d .venv ]]; then
          pdm venv create
        fi

        if [[ ! -f pyproject.toml ]]; then
          echo 'No pyproject.toml found. Use `pdm init` to create one first.'
          pdm init
        fi

        if [[ "$VIRTUAL_ENV" == "" ]]; then
          pdm use -q --venv in-project
          eval $(pdm venv activate in-project)

          export VIRTUAL_ENV=$(pwd)/.venv
          export PYTHONPATH=$VIRTUAL_ENV/lib/$(command ls $VIRTUAL_ENV/lib | head -1)/site-packages:$PYTHONPATH
          PATH_add "$VIRTUAL_ENV/bin"
        fi
      fi
    }
  '';

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs.home-manager.enable = true;
}
