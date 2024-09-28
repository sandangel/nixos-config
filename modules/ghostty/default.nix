{ lib, ... }:
lib.mkMerge [
  {
    xdg.configFile."ghostty".source = ./.;
    xdg.configFile."ghostty".recursive = true;
  }
]
