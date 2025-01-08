{ pkgs, ... }:
{
  # home.stateVersion = "22.05";
  home.packages = (
    with pkgs;
    [
      # Utilities
      glib
      gnumake
      # killall
      vim
      binutils
      bind

      # Fonts
      # comic-code
      # nerdfonts
      # nerd-fonts.jetbrains-mono

      # Nix
      nurl
      devenv
      cachix

      # Git
      gh
      # git

      # Rust toolchain
      # fenix.stable.toolchain
      # gcc

      # Image viewer
      chafa

      # Python toolchain
      rye
      # hatch
    ]
  );

  home.sessionVariables = rec {
    FZF_BIND_OPTS = "--bind page-up:preview-up,page-down:preview-down,?:toggle-preview";
    FZF_CTRL_T_COMMAND = "rg --files";
    FZF_CTRL_T_OPTS = "${FZF_PREVIEW_OPTS} ${FZF_BIND_OPTS}";
    FZF_DEFAULT_COMMAND = "rg --files";
    FZF_DEFAULT_OPTS = "--ansi --border ${FZF_BIND_OPTS}";
    FZF_PREVIEW_COMMAND = "bat {}";
    FZF_PREVIEW_OPTS = "--preview '${FZF_PREVIEW_COMMAND}'";
  };

  fonts.fontconfig.enable = true;

  programs.ripgrep.enable = true;
  programs.ripgrep.arguments = [
    "--follow"
    "--smart-case"
    "--hidden"
    "--glob=!.git/*"
    "--glob=!node_modules/*"
    "--glob=!*.lock"
    "--glob=!*-lock.json"
    "--glob=!*.min.{js,css}"
    "--glob=!*.lock.hcl"
    "--glob=!__snapshots__"
    "--glob=!dist"
  ];

  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  programs.eza.enable = true;
  programs.eza.icons = "auto";
  programs.eza.git = true;
  programs.eza.extraOptions = [
    "--group-directories-first"
    "--header"
  ];

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "TwoDark";
      style = "numbers,changes";
      color = "always";
    };
  };

  programs.info.enable = true;
  programs.nix-index.enable = true;
  programs.jq.enable = true;

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs.home-manager.enable = true;
}
