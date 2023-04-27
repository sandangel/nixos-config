{ pkgs, lib, config, username, ... }:

{
  home.username = username;
  home.stateVersion = "22.05";
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    alacritty
    exa
    gh
    go
    grpcurl
    istioctl
    kind
    kubectl
    kubectx
    kubeswitch
    pinniped
    postgresql
    skaffold
    vault
    vcluster
    ssm-session-manager-plugin
  ];

  xdg.enable = true;

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;

  imports = [
    ./zsh
    ./git
    ./kitty
    ./gnome
    ./nvim
    ./hypr
  ];

  home.sessionVariables = with pkgs; rec {
    FZF_BIND_OPTS = "--bind page-up:preview-up,page-down:preview-down,?:toggle-preview";
    FZF_CTRL_T_COMMAND = "${RG_FILE} ${RG_IGNORE}";
    FZF_CTRL_T_OPTS = "${FZF_PREVIEW_OPTS} ${FZF_BIND_OPTS}";
    FZF_DEFAULT_COMMAND = "${RG_FILE} ${RG_IGNORE}";
    FZF_DEFAULT_OPTS = "--ansi --border $FZF_BIND_OPTS";
    FZF_PREVIEW_COMMAND = "bat {}";
    FZF_PREVIEW_OPTS = "--preview '${FZF_PREVIEW_COMMAND}'";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    PAGER = "less -FirSwX";
    RG_FILE = "rg --files --hidden --follow";
    RG_GREP = "${RG_LINE} ${RG_IGNORE} ";
    RG_IGNORE = "--glob '!.git/*' --glob '!node_modules/*' --glob '!*.lock' --glob '!*-lock.json' --glob '!*.min.{js,css}' --glob '!*.lock.hcl' --glob '!__snapshots__/*'";
    RG_LINE = "rg --column --line-number --no-heading --smart-case --hidden --follow --color always";

    NIXOS_OZONE_WL = "1";
    GDK_SCALE = "2";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };

  fonts.fontconfig.enable = true;

  programs.zoxide.enable = true;
  programs.fzf.enable = true;

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
  programs.direnv.enableZshIntegration = false;
  programs.direnv.stdlib = ''
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    declare -A direnv_layout_dirs
    direnv_layout_dir() {
      echo "''${direnv_layout_dirs[$PWD]:=$(
        echo -n "$XDG_CACHE_HOME"/direnv/layouts/
        echo -n "$PWD" | shasum | cut -d ' ' -f 1
        )}"
    }

    use_flake() {
      watch_file flake.nix
      watch_file flake.lock
      eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
    }

    layout_poetry() {
      if [[ ! -f pyproject.toml ]]; then
        log_error 'No pyproject.toml found. Use `poetry new` or `poetry init` to create one first.'
        exit 2
      fi

      # create venv if it doesn't exist
      poetry run true

      export VIRTUAL_ENV=$(poetry env info --path)
      export POETRY_ACTIVE=1
      PATH_add "$VIRTUAL_ENV/bin"
    }
  '';

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Yaru";
    package = pkgs.yaru-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs.home-manager.enable = true;
}
