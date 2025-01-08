{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Cloud
    azure-cli
    google-cloud-sdk
    awscli2
    ssm-session-manager-plugin
    terraform
    vault
  ];
}
