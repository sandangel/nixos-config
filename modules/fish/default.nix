{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fd
    broot
    procs
    hexyl
    chafa
    nodejs
  ];
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      _bind_nvim_kitty
      set --global DIRENV_LOG_FORMAT ""
      ${pkgs.kubeswitch}/bin/switcher init fish | source
      set --global fifc_editor nvim
      set --global tide_left_prompt_items pwd git context jobs direnv docker node python rustc go gcloud kubectl terraform aws nix_shell status newline character
      set --global tide_right_prompt_items cmd_duration time
      set --global tide_git_truncation_length 100
    '';
    shellAliases = rec {
      cat = "bat --style auto";
      g = "git";
      ga = "git add";
      gb = "git branch";
      gc = "git commit --signoff";
      gco = "git checkout";
      gd = "git diff";
      gl = "git pull";
      gp = "git push";
      gst = "git status";
      k = "kubectl";
      kaf = "kubectl apply -f";
      kd = "kubectl describe";
      kdf = "kubectl delete -f";
      kg = "kubectl get";
      kgp = "kubectl get po";
      kn = "kubens";
      l = "${ls} -a";
      ll = "${ls} -lg";
      ls = "eza --group-directories-first --icons --sort time";
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
      ssh = "TERM=xterm-256color command ssh";
      tf = "terraform";
    };
    plugins = [
      {
        name = "autopair.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "refs/tags/1.0.4";
          sha256 = "sha256-s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU=";
        };
      }
      {
        name = "colored_man_pages.fish";
        src = pkgs.fetchFromGitHub {
          owner = "patrickf1";
          repo = "colored_man_pages.fish";
          rev = "f885c2507128b70d6c41b043070a8f399988bc7a";
          sha256 = "sha256-ii9gdBPlC1/P1N9xJzqomrkyDqIdTg+iCg0mwNVq2EU=";
        };
      }
      {
        name = "fifc";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fifc";
          rev = "refs/tags/v0.1.1";
          sha256 = "sha256-p5E4Mx6j8hcM1bDbeftikyhfHxQ+qPDanuM1wNqGm6E=";
        };
      }
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "refs/tags/v6.0.1";
          sha256 = "sha256-oLD7gYFCIeIzBeAW1j62z5FnzWAp3xSfxxe7kBtTLgA=";
        };
      }
    ];
    functions = {
      sw = {
        description = "Alias for Kubeswitch";
        wraps = "${pkgs.kubeswitch}/bin/switcher";
        body = ''
          kubeswitch $argv;
        '';
      };
      gfco = {
        description = "Git checkout local or remote branch with fzf interactive select";
        body = ''
          set -f branch (git branch -a --color | fzf --ansi | awk '{print $1}')
          set -f strip_remote_branch (echo $branch | sed 's/remotes\/origin\///')
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

          if string match -q "*kitty*" $terminal; or string match -q "*hatch*" $terminal
            set -g nvim_addr /tmp/nvim_kitty_tab_(kitty @ ls | jq -r '.[] | select(.is_focused == true).tabs[] | select(.is_focused == true).id')
          end
        '';
      };
      nvim = {
        description = "Open nvim with remote server aware";
        body = ''
          if test -z "$nvim_addr"
            _bind_nvim_kitty
            if test -z "$nvim_addr"
              command nvim $argv
              return
            end
          end
          set -f window_id (kitty @ ls | jq -r '.[] | select(.is_focused == true).tabs[] | select(.is_focused == true).windows[] | select(.foreground_processes[].cmdline[0] | endswith("nvim")).id')
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
}
