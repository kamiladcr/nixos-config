{ config, pkgs, lib,  ... }:

let
  user = "kamiladcr";
  sources = import ./npins/default.nix;
in
{
  imports = [
    "${sources.home-manager}/nixos" # Home dotfiles
    "${sources.Jovian-NixOS}/modules" # SteamOS
  ];

  powerManagement.enable = true;

  boot = {
    # Boot configuration
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;
    loader.systemd-boot.consoleMode = "max";

    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "oslo"; # hostname

  # Enable networkingc
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable compatibility with older applications
  programs.xwayland.enable = true;

  # Additional packages
  environment.systemPackages = with pkgs; [
    # Nix
    npins
    (writeShellScriptBin "nixos-switch" (builtins.readFile ./nixos-switch))

    # Niri
    wl-clipboard
    xwayland-satellite
    swaylock
    rofi-wayland

    # For gaming
    torzu # Nintendo emulator
    steam-rom-manager # Add Nintendo games to steam
  ];

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

  ################################
  ##### DESKTOP CONFIGURATION ####

  # Windows
  programs.niri.enable = true;

  # Environment variables
  environment.variables = {
    # Enable native support for chrome
    NIXOS_OZONE_WL = 1;
    # Use emacs by default
    EDITOR = "emacsclient";
  };

  # Home-directory configuration
  home-manager.useGlobalPkgs = true;
  home-manager.users.kamiladcr = {
    # Notifications
    services.dunst.enable = true;

    # Status bar
    programs.waybar.enable = true;
    programs.waybar.settings.main = {
      height = 20;
      layer = "top";
      position = "top";
      modules-left = [
        "niri/workspaces"
        "wlr/taskbar"
      ];
      modules-right = [
        "tray"
        "niri/language"
        "disk"
        "network"
        "clock"
        "battery"
        "custom/exit"
      ];
      "wlr/taskbar" = {
        on-click = "activate";
      };
      "niri/language" = {
        format = "{short}";
      };
      disk = {
        format = "{free}";
      };
      network = {
        interface = "wlp1s0";
        format = "{ifname}";
        format-wifi = "{essid} ({signalStrength}%)";
      };
      "custom/exit" = {
        format = "OUT";
        tooltip = "Touch to exit the session";
        on-click = "niri msg action quit --skip-confirmation";
      };
    };
    programs.waybar.style = ''
      * {
          background: transparent;
          color: white;
          padding: 0 3px;
          font-family: JetBrainsMono;
          font-size: 12px;
          border-radius: 0px;
      }
      #tray menu {
        background-color: #333333;
        color: white;
      }
      #tray menu menuitem:hover {
        background-color: gray;
      }
      #workspaces button.focused {
        background-color: #333333;
      }
      #battery.charging {
          background-color: #333333;
      }
    '';

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "JetBrains Mono 10";
      theme = "gruvbox-dark";
    };

    # Keeping home-manager and system state in sync
    home.enableNixpkgsReleaseCheck = false;
    home.stateVersion = "24.11";
  };

  ##############################
  ##### STEAM CONFIGURATION ####

  # Handheld Daemon to control hardware
  services.handheld-daemon = {
    inherit user;
    enable = true;
    ui.enable = true;
  };

  jovian.steam = {
    inherit user;
    enable = true;
    autoStart = true;
    desktopSession = "niri";
  };

  services.displayManager.autoLogin = {
    inherit user;
    enable = true;
  };

  jovian.decky-loader = {
    inherit user;
    enable = true;
  };

  programs.steam = {
    enable = true;
    extest.enable = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
