{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkMerge [
  {
    xdg.configFile."kitty".source = ./.;
    xdg.configFile."kitty".recursive = true;
  }

  (lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [ kitty ];
    xdg.desktopEntries.kitty = {
      name = "kitty";
      genericName = "Terminal emulator";
      exec = "${pkgs.nixGL}/bin/nixGL ${pkgs.kitty}/bin/kitty --start-as=maximized";
      icon = "kitty";
      comment = "Fast, feature-rich, GPU based terminal";
      categories = [
        "System"
        "TerminalEmulator"
      ];
    };

    xdg.configFile."autostart/kitty.desktop".source = "${config.home.homeDirectory}/.nix-profile/share/applications/kitty.desktop";
  })
]
