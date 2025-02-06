{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovide
  ];
  xdg.configFile."neovide".source = ./.;
  xdg.configFile."neovide".recursive = true;
}
