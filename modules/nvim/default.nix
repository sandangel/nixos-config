{ pkgs, inputs, ... }:
let
  nvchad = pkgs.callPackage ../../pkgs/nvchad { };
  rustToolchain = inputs.fenix.packages.${pkgs.system}.default.toolchain;
in
{
  home.packages = with pkgs; [
    actionlint
    bun
    codespell
    # corepack
    nixfmt
    nodejs
    nvchad
    stylelint
    tflint
    # tfsec
    rustToolchain
    trash-cli
    scooter
    # yamlfmt
    yamllint
    helm-ls
    lua-language-server
    # prettierd
    # https://github.com/mantoni/eslint_d.js/issues/287
    # eslint_d support eslint 9 with flat config
    # (eslint_d.overrideAttrs (oldAttrs: {
    #   nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];
    #   postInstall = ''
    #     wrapProgram $out/bin/eslint_d --set ESLINT_USE_FLAT_CONFIG=true
    #   '';
    # }))
    nixd
    statix
    vscode-langservers-extracted
    yaml-language-server
    vtsls
    # gopls
    # rust-analyzer
    terraform-ls
    tree-sitter
    tailwindcss-language-server
    docker-compose-language-service
    dockerfile-language-server
  ];
  programs.fd.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
  };

  imports = [
    ./neovide
  ];

  xdg.configFile."nvim" = {
    source = "${nvchad}";
    recursive = true;
  };
}
