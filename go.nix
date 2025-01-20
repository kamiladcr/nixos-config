{ config, pkgs, lib,  ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "oslo"; # hostname

  # Enable networking
  networking.networkmanager.enable = true;

  # OneDrive
  services.onedrive.enable = true;

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap
  services.xserver.xkb.layout = "us,ru,no";
  services.xserver.xkb.options = "grp:caps_toggle";

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Handheld Daemon to control hardware
  services.handheld-daemon = {
    enable = true;
    user = "kamiladcr";
    ui.enable = true;
  };

  # The last kernel since legend go is quite new
  boot.kernelPackages = pkgs.linuxPackages_latest;


  # Packages to be installed globally
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [
    lutris
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
