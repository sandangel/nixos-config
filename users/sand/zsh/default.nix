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

      __fzf_dir=${pkgs.fzf}
      . $XDG_CONFIG_HOME/zsh/config/init.zsh
      unset __fzf_dir
      . $XDG_CONFIG_HOME/zsh/config/nix.zsh
      . $XDG_CONFIG_HOME/zsh/config/alias.zsh
      . $XDG_CONFIG_HOME/zsh/config/kitty.zsh
      . $XDG_CONFIG_HOME/zsh/config/utils.zsh

      source <(${pkgs.kubeswitch}/bin/switcher init zsh)
      source <(${pkgs.kubeswitch}/bin/switcher completion zsh)
      source <(compdef _switcher switch)
    '';
  };
  xdg.configFile."zsh/config".source = ./.;
  xdg.configFile."zsh/config".recursive = true;
  xdg.configFile."zsh/.p10k.zsh".source = ./p10k.zsh;
}
