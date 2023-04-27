{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (kitty.overrideAttrs (o: {
      patches = (o.patches or [ ]) ++ [
        ./vmware-3d-accel-compat.patch
      ];
    }))
  ];
  xdg.configFile."kitty".source = ./.;
  xdg.configFile."kitty".recursive = true;
  xdg.desktopEntries.kitty = {
    type = "Application";
    name = "kitty";
    genericName = "Terminal emulator";
    comment = "Fast, feature-rich, GPU based terminal";
    exec = "kitty --start-as maximized -1";
    icon = "kitty";
    categories = [ "System" "TerminalEmulator" ];
  };

  home.sessionVariables = with pkgs; rec {
    TERMINFO_DIRS = "${kitty.terminfo}/share/terminfo";
  };
}
