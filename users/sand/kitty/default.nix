{ pkgs, ... }:
{
  xdg.configFile."kitty".source = ./.;
  xdg.configFile."kitty".recursive = true;
}
