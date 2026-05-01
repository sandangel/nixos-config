{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpaper
    xorg.xhost
    lxqt.lxqt-policykit
    clipse
    socat
    libnotify
  ];
  xdg.configFile."hypr/hyprpaper.conf".source = ./hyprpaper.conf;
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./hyprland.conf;
  wayland.windowManager.hyprland.xwayland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = true;
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
  programs.zsh = {
    initContent = ''
      if [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]]; then
        . $HOME/.nix-config/modules/hyprland/hyprland.zsh
      fi
    '';
  };
  programs.clipsync.enable = true;
  imports = [
    # ./dunst
    ../waybar
    ../wofi
    # ./swaync
  ];
}
