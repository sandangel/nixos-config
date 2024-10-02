{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpaper
    fuzzel
    xorg.xhost
    clipse
    xfce.thunar
    xfce.tumbler
    xfce.xfce4-terminal
    lxqt.lxqt-policykit
  ];
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "xdph"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
      };
    };
  };
  xdg.configFile."hypr/hyprpaper.conf".source = ./hyprpaper.conf;
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
