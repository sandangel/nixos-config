{ pkgs, lib, config, username, ... }:

{
  home.username = username;
  home.stateVersion = "22.05";
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    exa
    fd
    gh
    go
    gopls
    grpcurl
    istioctl
    kind
    kitty
    kubectl
    kubectx
    kubeswitch
    neovim-nightly
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.pnpm
    nodePackages.pyright
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodejs_latest
    pinniped
    postgresql
    ripgrep
    rnix-lsp
    skaffold
    sqlite
    lua-language-server
    terraform-ls
    tflint
    trash-cli
    tree-sitter
    vault
    vcluster
    yamlfmt
    (python3.withPackages (ps: with ps; [
      pynvim
      debugpy
      python-lsp-server
      pyls-isort
      python-lsp-black
      pylsp-mypy
    ]))
    ssm-session-manager-plugin
  ];

  xdg.enable = true;

  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;

  xdg.configFile."kitty".source = ./kitty;
  xdg.configFile."kitty".recursive = true;
  xdg.desktopEntries.kitty = {
    type = "Application";
    name = "kitty";
    genericName = "Terminal emulator";
    comment = "Fast, feature-rich, GPU based terminal";
    exec = "kitty --start-as maximized";
    icon = "kitty";
    categories = [ "System" "TerminalEmulator" ];
  };

  # xdg.configFile."wezterm".source = ./wezterm;
  # xdg.configFile."wezterm".recursive = true;

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;

  imports = [
    ./zsh/zsh.nix
  ];

  home.sessionVariables = with pkgs; rec {
    EDITOR = "nvim";
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
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${lib.makeLibraryPath [ sqlite libxkbcommon mesa stdenv.cc.cc.lib ]}";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MOZ_ENABLE_WAYLAND = "1";
    PAGER = "less -FirSwX";
    RG_FILE = "rg --files --hidden --follow";
    RG_GREP = "${RG_LINE} ${RG_IGNORE} ";
    RG_IGNORE = "--glob '!.git/*' --glob '!node_modules/*' --glob '!*.lock' --glob '!*-lock.json' --glob '!*.min.{js,css}' --glob '!*.lock.hcl' --glob '!__snapshots__/*'";
    RG_LINE = "rg --column --line-number --no-heading --smart-case --hidden --follow --color always";
    TERMINFO_DIRS = "${kitty.terminfo}/share/terminfo";
  };

  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    extraConfig = {
      github.user = "sandangel";
      push.default = "tracking";
      pull.ff = "only";
      init.defaultBranch = "main";
      "url \"ssh://git@github.com/\"".insteadOf = "https://github.com/";
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
      commit.verbose = true;
      pager = {
        diff = "delta";
        log = "delta";
        reflog = "delta";
        show = "delta";
      };
    };
    userName = "San Nguyen";
    userEmail = "vinhsannguyen91@gmail.com";
    includes = [{
      condition = "gitdir:~/Work/Woven/**";
      contents = {
        user.email = "san.nguyen@woven-planet.global";
        "url \"ssh://git@github.tri-ad.tech/\"".insteadOf = "https://github.tri-ad.tech/";
      };
    }];
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "side-by-side decorations";
        whitespace-error-style = "22 reverse";
        navigate = true;
      };
    };
  };

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

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme.selectedLineBgColor = [ "reverse" ];
      gui.theme.selectedRangeBgColor = [ "reverse" ];
      gui.showFileTree = false;
      git.paging.colorArg = "always";
      git.paging.pager = "delta --dark --paging=never";
      services."github.tri-ad.tech" = "github:github.tri-ad.tech";
      quitOnTopLevelReturn = true;
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
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
  };

  programs.home-manager.enable = true;
}
