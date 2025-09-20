{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.kubeswitch;
in
{
  options = {
    programs.kubeswitch = {
      enable = lib.mkEnableOption "kubeswitch";

      command = lib.mkOption {
        type = lib.types.str;
        default = "kswitch";
        description = "The name of the command to use";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.kubeswitch;
        defaultText = lib.literalExpression "pkgs.kubeswitch";
        description = "The package to install for kubeswitch";
      };
    };
  };

  config =
    let
      shell_files = pkgs.runCommand "kubeswitch-shell-files" { } ''
        mkdir -p $out/share
        for shell in bash zsh; do
          ${cfg.package}/bin/switcher init $shell | sed 's/switch(/${cfg.command}(/' > $out/share/${cfg.command}_init.$shell
          ${cfg.package}/bin/switcher --cmd ${cfg.command} completion $shell > $out/share/${cfg.command}_completion.$shell
        done
      '';
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      programs.bash.initExtra = ''
        source ${shell_files}/share/${cfg.command}_init.bash
        source ${shell_files}/share/${cfg.command}_completion.bash
      '';

      programs.zsh.initContent = ''
        autoload -U +X compinit && compinit

        source ${shell_files}/share/${cfg.command}_init.zsh
        source ${shell_files}/share/${cfg.command}_completion.zsh
      '';
    };
}
