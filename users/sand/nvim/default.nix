{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nvchad
  ];
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      gcc
      helm-ls
      trash-cli
    ];
    extraLuaPackages = ps: with ps; [ sqlite ];
  };

  xdg.configFile."nvim" = {
    source = "${pkgs.nvchad}";
  };
}
