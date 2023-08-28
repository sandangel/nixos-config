{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    extraLuaPackages = ps: with ps; [ sqlite ];
    extraLuaConfig = builtins.readFile ./init.lua;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
    ];
  };
}
