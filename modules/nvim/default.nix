{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    nvchad
    bun
    nodejs
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
      lua-language-server
      rnix-lsp
      pyright
      vscode-langservers-extracted
      yaml-language-server
      actionlint
      gopls
      rust-analyzer
      terraform-ls
      tflint
      tfsec
      yamlfmt
      yamllint
      tree-sitter
      (python3.withPackages (ps: with ps; [
        python-lsp-server
        pyls-isort
        python-lsp-black
        pylsp-mypy
        python-lsp-ruff
        ruff-lsp
      ]))
    ] ++ (with pkgs.nodePackages; [
      typescript-language-server
      docker-compose-language-service
      dockerfile-language-server-nodejs
    ]);
    extraLuaPackages = ps: with ps; [ sqlite ];
  };

  xdg.configFile."nvim" = {
    source = "${pkgs.nvchad}";
  };
}
