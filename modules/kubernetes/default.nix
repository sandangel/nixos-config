{ pkgs, ... }:

{
  home.packages = with pkgs; [
    k9s
    kubectl
    kubectx
    kubeswitch
    pinniped
    vcluster
    kind
    kubernetes-helm
  ];

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;
}
