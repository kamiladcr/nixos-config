{ config, pkgs, lib,  ... }:

{
  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda";

  # FIXME: UUID detection is currently broken
  boot.loader.grub.fsIdentifier = "provided";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  powerManagement.enable = false;
  virtualisation.virtualbox.guest.enable = true;
  system.stateVersion = lib.trivial.release;
}
