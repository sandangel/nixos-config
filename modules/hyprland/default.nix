{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpaper
  ];
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./hyprland.conf;
  wayland.windowManager.hyprland.xwayland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = true;
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
  programs.zsh = {
    initExtra = ''
      . $HOME/.nix-config/modules/hyprland/hyprland.zsh
    '';
  };
  imports = [
    ./dunst
  ];
}
