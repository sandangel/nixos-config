{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # wl-clipboard # disabled because of screen flash. It needs to steal the focus to copy to clipboard on Wayland
    xclip
  ];
}
