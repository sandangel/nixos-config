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
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    _JAVA_AWT_WM_NONREPARENTING = "1"; # Fix for Java applications on tiling window managers
  };
  imports = [
    ./dunst
  ];
}
