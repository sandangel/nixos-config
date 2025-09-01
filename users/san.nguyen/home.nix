{ pkgs, ... }:
let
  comic-code = pkgs.callPackage ../../pkgs/comic-code { };
in
{
  home.username = "sand";
  home.homeDirectory = "/Users/sand";
  home.packages = with pkgs; [
    # System utilities
    # coreutils
    # bind

    # Apple Silicon monitoring tool
    # asitop

    # Apple native container tool
    container

    # Fonts
    comic-code
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  imports = [
    ../../modules/direnv
    ../../modules/git
    # ../../modules/kitty
    ../../modules/misc
    # ../../modules/nvim
    ../../modules/zsh
  ];

  fonts.fontconfig.enable = true;

  home.stateVersion = "24.05";
}
