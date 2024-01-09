{ pkgs, lib, config, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  imports = [
    ../../modules/direnv
    ../../modules/git
    ../../modules/kitty
    ../../modules/misc
    ../../modules/nvim
    ../../modules/zsh
  ];
}
