{ pkgs, username, ... }:

{
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    packages = with pkgs; [
      # System utilities
      gnused
      coreutils
      bind

      # Apple Silicon monitoring tool
      asitop

      docker-client
    ];
    stateVersion = "26.05";
  };
  imports = [
    ../../modules/direnv
    ../../modules/git
    ../../modules/kitty
    ../../modules/misc
    ../../modules/nvim
    ../../modules/zsh
  ];
}
