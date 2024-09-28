{ lib, pkgs, ... }:
lib.mkMerge [
  {
    xdg.configFile."ghostty".source = ./.;
    xdg.configFile."ghostty".recursive = true;
    home.packages = with pkgs; [
      ghostty
    ];
  }
]
