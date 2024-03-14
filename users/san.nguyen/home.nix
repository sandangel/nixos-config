{ pkgs, lib, config, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.packages = with pkgs; [
    # System utilities
    gnused
    coreutils

    # Apple Silicon monitoring tool
    asitop
  ];
  imports = [
    ../../modules/direnv
    ../../modules/git
    ../../modules/kitty
    ../../modules/misc
    ../../modules/nvim
    ../../modules/zsh
  ];
}
