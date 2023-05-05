{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    extraPython3Packages = ps: with ps; [
      pynvim
      python-lsp-server
      pyls-isort
      python-lsp-black
      pylsp-mypy
    ];
    extraLuaPackages = ps: with ps; [ sqlite ];
    extraLuaConfig = builtins.readFile ./init.lua;
    extraPackages = with pkgs; [
      lua-language-server
      terraform-ls
      gopls
      rnix-lsp
      tflint
      trash-cli
      fd
      ripgrep
      tree-sitter
    ] ++ (with pkgs.nodePackages; [
      dockerfile-language-server-nodejs
      pnpm
      pyright
      vscode-langservers-extracted
      yaml-language-server
    ]);
    plugins = with pkgs.vimPlugins; [
      {
        plugin = sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
    ];
  };
}
