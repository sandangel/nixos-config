{ pkgs, config, lib, ... }:
{
  home.packages = with pkgs; [
    kitty
  ];
  xdg.configFile."kitty".source = ./.;
  xdg.configFile."kitty".recursive = true;
}
