{ pkgs, ... }:

{
  home.packages = with pkgs; [
    k9s
    # kind
    kubectl
    # kubectx
    # kubernetes-helm
    pinniped
    # skaffold
    # vcluster
  ];

  imports = [ ../programs/kubeswitch.nix ];

  programs.kubeswitch.enable = true;

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;
}
