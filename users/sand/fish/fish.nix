{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      _bind_nvim_kitty
      set -x DIRENV_LOG_FORMAT ""
    '';
    shellAliases = {
      k = "kubectl";
      kb = "kubie";
      kg = "kubectl get";
      kd = "kubectl describe";
      kgp = "kubectl get po";
      kaf = "kubectl apply -f";
      kdf = "kubectl delete -f";
      tf = "terraform";
      tfinfra = "aws-woven-auth infra run terraform";
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
}
