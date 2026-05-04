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
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
  };
  programs = {
    zsh.initContent = ''
      if [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]]; then
        . $HOME/.nix-config/modules/hyprland/hyprland.zsh
      fi
    '';
    clipsync.enable = true;
  };
  imports = [
    # ./dunst
    ../waybar
    ../wofi
    # ./swaync
  ];
}
