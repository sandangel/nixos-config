# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  modulesPath,
  ...
}:

{
  boot.initrd.kernelModules = [ "virtio-gpu" ];
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
}
