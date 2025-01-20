{ config, pkgs, lib,  ... }:

# Desktop environment
services.xserver = {
  videoDrivers = [ "virtualbox" "vmware" "cirrus" "vesa" "modesetting" ];
};

# Windows file share
fileSystems."/mnt/windows" = {
  fsType = "vboxsf";
  device = "N";
  options = [ "rw" ];
};

# fileSystems."/mnt/sdrive" = {
#   fsType = "vboxsf";
#   device = "S";
#   options = [ "rw" ];
# };

# Allow accessing to any ports on this VM
networking.firewall.enable  = false;

# Allow connecting through ssh (remote connection)
services.openssh.enable = true;

# Guest additions for virtual box
virtualisation.virtualbox.guest.enable = true;
}
