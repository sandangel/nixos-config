{ pkgs, ... }:
{
  xdg.configFile."hypr".source = ./.;
  home.packages = with pkgs; [ hyprpaper ];
  programs.zsh = {
    initExtra = ''
      . $HOME/.config/hypr/hyprland.zsh
    '';
  };
  imports = [
    ./dunst
  ];
}
