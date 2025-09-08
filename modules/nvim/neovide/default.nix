{ pkgs, ... }:
{
  programs.neovide.enable = true;
  programs.neovide.settings = (builtins.fromTOML (builtins.readFile ./config.toml));
}
