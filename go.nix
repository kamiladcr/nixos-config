{ config, pkgs, lib,  ... }:

let
  sources = import ./npins/default.nix;
in
{
  imports = [
    "${sources.home-manager}/nixos" # Home dotfiles
    "${sources.Jovian-NixOS}/modules" # SteamOS
    ./desktop.nix
    ./steam.nix
  ];

  # Enable power saving defaults
  powerManagement.enable = true;

  boot = {
    # Boot configuration
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 0;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
    };

    # Kernel config
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "zenpower" "acpi_call" ];

    # Disable default CPU sensor
    blacklistedKernelModules = [ "k10temp" ];

    extraModulePackages = with config.boot.kernelPackages; [
      zenpower # better CPU sensors
      acpi_call # TDP controls
    ];
  };

  networking.hostName = "oslo"; # hostname

  # Enable networkingc
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Additional system packages
  environment.systemPackages = with pkgs; [
    # Nix
    npins
    (writeShellScriptBin "nixos-switch" (builtins.readFile ./nixos-switch))

    # Utils
    htop
  ];

  # Configure keymap
  services.xserver.xkb.layout = "us,ru,no";
  services.xserver.xkb.options = "grp:caps_toggle";

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
