{ ... }:
{
  xdg.configFile."hypr".source = ./.;
  programs.zsh = {
    initExtra = ''
      . $HOME/.config/hypr/hyprland.zsh
    '';
  };
  imports = [
    ./dunst
  ];
}
