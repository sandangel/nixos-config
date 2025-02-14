{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.packages = with pkgs; [
    # System utilities
    gnused
    coreutils
    bind

    # Apple Silicon monitoring tool
    asitop

    docker-client
  ];
  imports = [
    ../../modules/direnv
    ../../modules/git
    ../../modules/kitty
    ../../modules/misc
    ../../modules/nvim
    ../../modules/zsh
  ];

  home.stateVersion = "24.05";
}
