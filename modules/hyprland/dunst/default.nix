{ pkgs, ... }:
{
  xdg.configFile."dunst".source = ./.;
  xdg.configFile."dunst".recursive = true;
  home.packages = with pkgs; [ dunst ];
}
