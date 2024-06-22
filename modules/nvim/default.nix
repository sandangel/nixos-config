{ pkgs, ... }:

{
  home.packages = with pkgs; [
    actionlint
    bun
    codespell
    corepack
    nixfmt-rfc-style
    nodejs
    nvchad
    stylelint
    tflint
    tfsec
    trash-cli
    yamlfmt
    yamllint
  ];
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages =
      (with pkgs; [
        helm-ls
        lua-language-server
        prettierd
        eslint_d
        nixd
        vscode-langservers-extracted
        yaml-language-server
        gopls
        rust-analyzer
        terraform-ls
        tree-sitter
        docker-compose-language-service
      ])
      ++ (with pkgs.nodePackages; [
        typescript-language-server
        dockerfile-language-server-nodejs
      ]);
  };

  xdg.configFile."nvim" = {
    source = "${pkgs.nvchad}";
  };
}
