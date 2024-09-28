{ pkgs, lib, ... }:
lib.mkMerge [
  {
    programs.kitty.enable = true;
    xdg.configFile."kitty".source = ./.;
    xdg.configFile."kitty".recursive = true;
    programs.zsh = {
      initExtra = ''
        . $HOME/.config/kitty/kitty.zsh
      '';
    };
  }

  (lib.mkIf pkgs.stdenv.isLinux {
    # home.packages = with pkgs; [ kitty ];
    xdg.desktopEntries.kitty = {
      name = "kitty";
      genericName = "Terminal emulator";
      exec = "kitty --detach --single-instance --start-as=maximized";
      icon = "kitty";
      comment = "Fast, feature-rich, GPU based terminal";
      categories = [
        "System"
        "TerminalEmulator"
      ];
    };
  })
]
