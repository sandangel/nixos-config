{ pkgs, lib, pkgs-unstable, config, ... }:

{
  home.packages = with pkgs-unstable; [
    ripgrep
    fd
    kubectl
    tree-sitter
    neovim-nightly
    pinniped
    kubeswitch
    exa
    kitty
    yaml-language-server
    trash-cli
    rnix-lsp
    nodejs
    nodePackages.pyright
    poetry
    python3
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

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;

  programs.firefox.enable = true;
  programs.firefox.package = pkgs.firefox.override {
    cfg = {
      enableGnomeExtensions = true;
    };
  };

  imports = [
    ./zsh/zsh.nix
  ];

  home.sessionVariables = rec {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MOZ_ENABLE_WAYLAND = "1";
    TERMINFO_DIRS = "${pkgs-unstable.kitty.terminfo}/share/terminfo";
    RG_IGNORE = "--glob '!.git/*' --glob '!node_modules/*' --glob '!*.lock' --glob '!*-lock.json' --glob '!*.min.{js,css}' --glob '!*.lock.hcl' --glob '!__snapshots__/*'";
    RG_LINE = "rg --column --line-number --no-heading --smart-case --hidden --follow --color always";
    RG_GREP = "${RG_LINE} ${RG_IGNORE} ";
    RG_FILE = "rg --files --hidden --follow";
    FZF_BIND_OPTS = "--bind page-up:preview-up,page-down:preview-down,?:toggle-preview";
    FZF_PREVIEW_COMMAND = "bat {}";
    FZF_PREVIEW_OPTS = "--preview '${FZF_PREVIEW_COMMAND}'";
    FZF_DEFAULT_OPTS = "--ansi --border $FZF_BIND_OPTS";
    FZF_DEFAULT_COMMAND = "${RG_FILE} ${RG_IGNORE}";
    FZF_CTRL_T_COMMAND = "${RG_FILE} ${RG_IGNORE}";
    FZF_CTRL_T_OPTS = "${FZF_PREVIEW_OPTS} ${FZF_BIND_OPTS}";
  };

  fonts.fontconfig.enable = true;

  xdg.configFile."git/woven".source = ./woven/gitconfig;
  programs.git = {
    enable = true;
    extraConfig = {
      github.user = "sandangel";
      push.default = "tracking";
      pull.ff = "only";
      init.defaultBranch = "main";
      "includeIf \"gitdir/i:~/Work/Woven/\"".path = "${config.xdg.configHome}/git/woven";
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
  programs.gh.enable = true;
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
  programs.direnv.enableZshIntegration = true;
  programs.direnv.stdlib = ''
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    declare -A direnv_layout_dirs
    direnv_layout_dir() {
      echo "''${direnv_layout_dirs[$PWD]:=$(
        echo -n "$XDG_CACHE_HOME"/direnv/layouts/
        echo -n "$PWD" | shasum | cut -d ' ' -f 1
        )}"
    }
  '';

  programs.home-manager.enable = true;
}
