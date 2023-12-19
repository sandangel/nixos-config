{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    kitty
  ];
  xdg.configFile."kitty".source = ./.;
  xdg.configFile."kitty".recursive = true;
  xdg.desktopEntries.kitty = {
    name = "kitty";
    genericName = "Terminal emulator";
    exec = "${pkgs.nixGL}/bin/nixGL ${pkgs.kitty}/bin/kitty --start-as=maximized";
    icon = "kitty";
    comment = "Fast, feature-rich, GPU based terminal";
    categories = [ "System" "TerminalEmulator" ];
  };
  xdg.configFile."autostart/kitty.desktop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-profile/share/applications/kitty.desktop";
}
