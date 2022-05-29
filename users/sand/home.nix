{ pkgs, pkgs-22-05, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    bat
    fzf
    lazygit
    fd
    jq
    gh
    kubectl
    terraform
    tree-sitter
    zoxide
    gh
    kubie
    yaru-theme
    kitty
    neovim-nightly
  ];

  xdg = {
    enable = true;
    configFile."wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;
    configFile."nvim/init.lua".source = ./init.lua;
    configFile."starship.toml".source = ./starship.toml;
    configFile."lazygit/config.yml".source = ./lazygit/config.yml;
    configFile."bat.conf".source = ./bat.conf;

    configFile."kitty".source = ./kitty;
    configFile."kitty".recursive = true;
    dataFile."applications/kitty.desktop".source = ./kitty/kitty.desktop;
  };

  home.file.".gitconfig-woven".source = ./gitconfig-woven;
  home.file.".mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source = "${pkgs-22-05.chrome-gnome-shell}/lib/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";

  home.sessionVariables = rec {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    MOZ_ENABLE_WAYLAND = "1";
    BAT_CONFIG_PATH = "$XDG_CONFIG_HOME/bat.conf";
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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      _bind_nvim_kitty
      set -x DIRENV_LOG_FORMAT ""
    '';
    shellAliases = {
      lg = "lazygit";
      g = "git";
      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gl = "git pull";
      gp = "git push";
      gst = "git status";
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
    };
    functions = {
      gfco = {
        description = "Git checkout local or remote branch with fzf interactive select";
        body = ''
          set -f branch (git branch -a --color | fzf --ansi | awk '{print $1}')
          set -f strip_remote_branch (echo $branch | sed 's/remotes\/origin\//')
          git checkout $strip_remote_branch
        '';
      };
      gdmb = {
        description = "Git delete merged branch";
        body = ''
          if string match -q "* main" (git branch)
            git checkout main
          else
            git checkout master
          end
          git pull
          if string match -q "Darwin" (uname -s)
            comm -12 (git branch | sed "s/ *//g" | psub) (git remote prune origin | sed "s/^.*origin\///g" | psub) | xargs -L1 -J % git branch -D %
          else if string match -q "Linux" (uname -s)
            comm -12 (git branch | sed "s/ *//g" | sort | psub) (git remote prune origin | sed "s/^.*origin\///g" | sort | psub) | xargs -r -I % git branch -D %
          end
        '';
      };
      gflg = {
        description = "Git log commit hash and copy selection";
        body = ''
          set -f hash (git log --oneline --color | fzf --ansi --preview-window right:60% --preview 'echo {} | cut -c1-7 | xargs git show --color | delta' | awk '{print $1}')
          if test -n "$hash"
            echo -ne "$hash" | pbcopy
          end
        '';
      };
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
      _bind_nvim_kitty = {
        description = "Export nvim remote address with attached kitty tab";
        body = ''
          set -f terminal_pid (ps -h -o ppid -p $fish_pid | tr -d '[:space:]')
          set -f terminal (ps -h -o comm -p $terminal_pid | tr -d '[:space:]')

          if string match -q "*kitty*" $terminal
            set -g nvim_addr /tmp/nvim_kitty_tab_(kitty @ ls | jq -r '.[] | select(.is_focused == true).tabs[] | select(.is_focused == true).id')
          end
        '';
      };
      nvim = {
        description = "Open nvim with remote server aware";
        body = ''
          if ! set -q nvim_addr
            command nvim $argv
            return
          end
          set -f window_id (kitty @ ls | jq -r '.[] | select(.is_focused == true).tabs[] | select(.is_focused == true).windows[] | select(.foreground_processes[].cmdline[0]== "nvim").id')
          if test -z "$window_id" && test -f $nvim_addr
            rm $nvim_addr
          end

          set -f session_folder "$HOME/.vim/sessions"
          set -f session_name (string join "" $session_folder/ (echo (pwd) | sed "s|$HOME/||" | sed 's|/|.|g') .vim)

          if test (count $argv) -eq 0 && test -z "$window_id" && test -f $session_name
            command nvim -c "source $session_name" --listen $nvim_addr
          else if test (count $argv) -eq 0 && test -z "$window_id" && ! test -f $session_name
            command nvim -c "mks $session_name" --listen $nvim_addr
          else if test (count $argv) -eq 0 && test -n "$window_id"
            kitty @ focus-window -m "id:$window_id" --no-response
          else if test (count $argv) -gt 0 && test -z "$window_id"
            command nvim --listen $nvim_addr $argv
          else if test (count $argv) -gt 0 && test -n "$window_id"
            command nvim --server $nvim_addr --remote $argv
            kitty @ focus-window -m "id:$window_id" --no-response
          else
            command nvim --listen $nvim_addr
          end
        '';
      };
    };
  };

  programs.git = {
    enable = true;
    extraConfig = {
      github.user = "sandangel";
      push.default = "tracking";
      pull.ff = "only";
      init.defaultBranch = "main";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      "includeIf \"gitdir/i:~/Work/Woven/\"".path = "~/.gitconfig-woven";
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
      commit.verbose = true;
      pager = {
        diff = "${pkgs.delta}/bin/delta";
        log = "${pkgs.delta}/bin/delta";
        reflog = "${pkgs.delta}/bin/delta";
        show = "${pkgs.delta}/bin/delta";
      };
    };
    userName = "San Nguyen";
    userEmail = "vinhsannguyen91@gmail.com";
    delta = {
      enable = true;
      options =  {
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

  programs.starship.enable = true;
  programs.zoxide.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.home-manager.enable = true;
}
