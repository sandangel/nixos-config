{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.clipsync;
  clipsync = pkgs.writeShellScriptBin "clipsync" (builtins.readFile ./scripts/clipsync.sh);
  deps = with pkgs; [
    xclip
    wl-clipboard
    clipnotify
  ];
in
{
  options = {
    programs.clipsync = {
      enable = lib.mkEnableOption "clipsync";
      enableClipboardManager = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Add Clipboard Manager sync";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = deps ++ [ clipsync ];

    systemd.user.services = lib.mkMerge [
      (lib.mkIf cfg.enableClipboardManager {
        clipboard-manager = {
          Unit = {
            Description = "Sync clipboard to Clipboard Manager";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
          };
        };
      })
      {
        wl-x11-sync = {
          Unit = {
            Description = "Sync Wayland clipboard to X11";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Service = {
            Environment = [
              "PATH=$PATH:${lib.makeBinPath (deps ++ [ clipsync ])}"
            ];
            ExecStart = "${clipsync}/bin/clipsync start wl-clipboard";
            ExecStop = "${clipsync}/bin/clipsync stop";
          };
        };
        x11-wl-sync = {
          Unit = {
            Description = "Sync X11 clipboard to Wayland";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Service = {
            Environment = [
              "PATH=$PATH:${lib.makeBinPath (deps ++ [ clipsync ])}"
            ];
            ExecStart = "${clipsync}/bin/clipsync start xclip";
            ExecStop = "${clipsync}/bin/clipsync stop";
          };
        };
      }
    ];
  };
}
