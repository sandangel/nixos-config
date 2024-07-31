{ pkgs, ... }:

{
  home.packages =
    with pkgs;
    (
      [
        actionlint
        bun
        codespell
        corepack
        nixfmt-rfc-style
        nodejs
        nvchad
        stylelint
        tflint
        # tfsec
        trash-cli
        # yamlfmt
        yamllint
        # helm-ls
        lua-language-server
        # prettierd
        # https://github.com/mantoni/eslint_d.js/issues/287
        # eslint_d support eslint 9 with flat config
        (eslint_d.overrideAttrs (oldAttrs: {
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];
          postInstall = ''
            wrapProgram $out/bin/eslint_d --set ESLINT_USE_FLAT_CONFIG=true
          '';
        }))
        nixd
        vscode-langservers-extracted
        yaml-language-server
        # gopls
        # rust-analyzer
        terraform-ls
        tree-sitter
        docker-compose-language-service
      ]
      ++ (with nodePackages; [
        typescript-language-server
        dockerfile-language-server-nodejs
      ])
    );

  xdg.configFile."nvim" = {
    source = "${pkgs.nvchad}";
  };
}
