{ pkgs, lib, config, username, ... }:

{
  home.packages = with pkgs; [
    k9s
    kubectl
    kubectx
    kubeswitch
    pinniped
    vcluster
  ];

  home.file.".kube/switch-config.yaml".source = ./switch-config.yaml;
}
