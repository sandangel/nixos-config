{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    envExtra = builtins.readFile ./zshenv;
    dotDir = ".config/zsh";
    enableCompletion = true;
    defaultKeymap = "emacs";
    history.path = "${config.xdg.configHome}/zsh/.zsh_history";
    completionInit = "";
    initContent = ''
      export DIRENV_LOG_FORMAT=

      # Set fzf folder for z4h so it won't install another fzf
      __fzf_dir=${pkgs.fzf}
      . $HOME/.config/zsh/config/init.zsh
      unset __fzf_dir
      . $HOME/.config/zsh/config/nix.zsh
      # There is a bug in home-manager zsh-abbr module that not sourcing the file
      . $HOME/.config/zsh/plugins/zsh-abbr/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh
      . $HOME/.config/zsh/config/utils.zsh

      export PATH=$HOME/.rye/shims:$PATH
      source <(${pkgs.rye}/bin/rye self completion)

      if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      if command -v uv &> /dev/null; then
        eval "$(uv generate-shell-completion zsh)"
      fi
      if command -v uvx &> /dev/null; then
        eval "$(uvx --generate-shell-completion zsh)"
      fi
    '';
    zsh-abbr.enable = true;
    zsh-abbr.abbreviations = {
      cat = "bat --style full";
      ssh = "TERM=xterm-256color ssh";
      tf = "terraform";
      k = "kubectl";
      kn = "kubens";
      kg = "kubectl get";
      kd = "kubectl describe";
      kgp = "kubectl get po";
      kaf = "kubectl apply -f";
      kdf = "kubectl delete -f";
      g = "git";
      ga = "git add";
      gb = "git branch";
      gc = "git commit --signoff";
      gco = "git checkout";
      gd = "git diff";
      gl = "git pull";
      gp = "git push";

      gs = "git status";
      rm = "trash";

      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
      sw = "kswitch";

      cs = "gh copilot suggest";
      ce = "gh copilot explain";
    };
  };
  xdg.configFile."zsh/config".source = ./.;
  xdg.configFile."zsh/config".recursive = true;
  xdg.configFile."zsh/.p10k.zsh".source = ./p10k.zsh;
}
