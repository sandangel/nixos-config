{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    nvchad
    bun
    nodejs
    fd
    nixfmt-rfc-style
    actionlint
    tflint
    tfsec
    yamlfmt
    yamllint
    trash-cli
  ];
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages =
      with pkgs;
      [
        helm-ls
        lua-language-server
        nixd
        pyright
        vscode-langservers-extracted
        yaml-language-server
        gopls
        rust-analyzer
        terraform-ls
        tree-sitter
        (python3.withPackages (
          ps: with ps; [
            python-lsp-server
            pylsp-mypy
            python-lsp-ruff
            ruff-lsp
          ]
        ))
      ]
      ++ (with pkgs.nodePackages; [
        typescript-language-server
        docker-compose-language-service
        dockerfile-language-server-nodejs
      ]);
  };

  xdg.configFile."nvim" = {
    source = "${pkgs.nvchad}";
  };
}
