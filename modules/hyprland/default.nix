{ pkgs, ... }:
let
  clipsync = pkgs.writeShellScriptBin "clipsync" (builtins.readFile ./scripts/hypr-clipsync.sh);
in
{
  home.packages = with pkgs; [
    hyprpaper
    xorg.xhost
    lxqt.lxqt-policykit
    clipse
    socat
    clipsync
    libnotify
  ];
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
    # ./dunst
    ./waybar
    ./wofi
    # ./swaync
  ];
}
