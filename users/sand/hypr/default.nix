{ pkgs, default, ... }:
{
  # enable hyprland
  wayland.windowManager.hyprland = {
    enable = false;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    nvidiaPatches = false;
  };

  home.packages = with pkgs; [
    jaq
    xorg.xprop
  ];

  imports = [
    ./wofi
    ./hyprpaper
    ./dunst
    ./config.nix
  ];

  programs.eww-hyprland = {
    enable = false;
  };

  services.kanshi = {
    enable = false;
    systemdTarget = "graphical-session.target";
  };

  # fake a tray to let apps start
  # https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}
