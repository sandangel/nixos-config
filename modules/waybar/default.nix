{ pkgs, ... }:
{
  xdg.configFile."waybar".source = ./.;
  xdg.configFile."waybar".recursive = true;
  home.packages = with pkgs; [ waybar ];
}
