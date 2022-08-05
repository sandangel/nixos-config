{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.vmware.guest;
  open-vm-tools = if cfg.headless then pkgs.open-vm-tools-headless else pkgs.open-vm-tools;
  xf86inputvmmouse = pkgs.xorg.xf86inputvmmouse;
  xf86videovmware = pkgs.xorg.xf86videovmware;
in
{
  imports = [
    (mkRenamedOptionModule [ "services" "vmwareGuest" ] [ "virtualisation" "vmware" "guest" ])
  ];

  options.virtualisation.vmware.guest = {
    enable = mkEnableOption "VMWare Guest Support";
    headless = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to disable X11-related features.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [ ];

    boot.initrd.availableKernelModules = [ "mptspi" ];

    environment.systemPackages = [ open-vm-tools ];

    systemd.services.vmware =
      {
        description = "VMWare Guest Service";
        wantedBy = [ "multi-user.target" ];
        after = [ "display-manager.service" ];
        unitConfig.ConditionVirtualization = "vmware";
        serviceConfig.ExecStart = "${open-vm-tools}/bin/vmtoolsd";
      };

    # Mount the vmblock for drag-and-drop and copy-and-paste.
    systemd.mounts = mkIf (!cfg.headless) [
      {
        description = "VMware vmblock fuse mount";
        documentation = [ "https://github.com/vmware/open-vm-tools/blob/master/open-vm-tools/vmblock-fuse/design.txt" ];
        unitConfig.ConditionVirtualization = "vmware";
        what = "${open-vm-tools}/bin/vmware-vmblock-fuse";
        where = "/run/vmblock-fuse";
        type = "fuse";
        options = "subtype=vmware-vmblock,default_permissions,allow_other";
        wantedBy = [ "multi-user.target" ];
      }
    ];

    security.wrappers.vmware-user-suid-wrapper = mkIf (!cfg.headless) {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${open-vm-tools}/bin/vmware-user-suid-wrapper";
    };

    environment.etc.vmware-tools.source = "${open-vm-tools}/etc/vmware-tools/*";

    services.xserver = mkIf (!cfg.headless) {
      modules = [ xf86inputvmmouse xf86videovmware ];

      config = ''
        Section "InputClass"
          Identifier "VMMouse"
          MatchDevicePath "/dev/input/event*"
          MatchProduct "ImPS/2 Generic Wheel Mouse"
          Driver "vmmouse"
        EndSection
      '';

      displayManager.sessionCommands = ''
        ${open-vm-tools}/bin/vmware-user-suid-wrapper
      '';
    };

    services.udev.packages = [ open-vm-tools ];
  };
}
