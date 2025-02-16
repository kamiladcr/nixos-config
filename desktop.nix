{ pkgs, lib, config, ... }:

{
  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable compatibility with older applications
  programs.xwayland.enable = true;

  # Windows
  programs.niri.enable = true;

  # Disable gnome keyring so that Chromium is not showing a popup
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Additional desktop packages
  environment.systemPackages = with pkgs; [
    # Niri
    wl-clipboard
    xwayland-satellite
    swaylock
    rofi-wayland
  ];

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
      clock = {
        format = "{:%d-%m-%Y %H:%M}";
      };
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


    # Configure pointer
    home.pointerCursor = {
      name = "Bibata-Original-Classic";
      x11.enable = true;
      gtk.enable = true;
      package = pkgs.bibata-cursors;
    };

    gtk = {
      enable = true;
      cursorTheme = {
        name = "Bibata-Original-Classic";
        package = pkgs.bibata-cursors;
      };
    };

    # Keeping home-manager and system state in sync
    home.enableNixpkgsReleaseCheck = false;
    home.stateVersion = config.system.stateVersion;
  };
}
