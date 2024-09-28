{ ... }:
{
  programs.alacritty.enable = true;
  xdg.configFile."alacritty".source = ./.;
  xdg.configFile."alacritty".recursive = true;
}
