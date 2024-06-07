{ pkgs, ... }:

{
  home.packages = with pkgs; [
    k9s
    kind
    kubectl
    kubectx
    kubernetes-helm
    kubeswitch
    pinniped
    skaffold
    vcluster
  ];

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;
}
