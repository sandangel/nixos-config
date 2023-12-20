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
    initExtra = ''
      export DIRENV_LOG_FORMAT=

      # Set fzf folder for z4h so it won't install another fzf
      __fzf_dir=${pkgs.fzf}
      . $XDG_CONFIG_HOME/zsh/config/init.zsh
      unset __fzf_dir

      # There is a bug in home-manager zsh-abbr module that not sourcing the file
      . $XDG_CONFIG_HOME/zsh/plugins/zsh-abbr/share/zsh/zsh-abbr/abbr.plugin.zsh

      . $XDG_CONFIG_HOME/zsh/config/kitty.zsh
      . $XDG_CONFIG_HOME/zsh/config/utils.zsh

      source <(${pkgs.kubeswitch}/bin/switcher init zsh)
      source <(${pkgs.kubeswitch}/bin/switcher completion zsh)
      source <(compdef _switcher switch)
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

      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
      sw = "switch";

      # Woven
      tfinfra = "ccli run --profile mdp-infra-admin terraform --";
    };
  };
  xdg.configFile."zsh/config".source = ./.;
  xdg.configFile."zsh/config".recursive = true;
  xdg.configFile."zsh/.p10k.zsh".source = ./p10k.zsh;
}
