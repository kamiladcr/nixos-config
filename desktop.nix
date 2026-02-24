{ pkgs, lib, config, ... }:

{
  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable compatibility with older applications
  programs.xwayland.enable = true;

  # Windows
  programs.niri.enable = true;
  programs.ewm.enable = true;

  # Shell (top panel)
  programs.dms-shell = {
    enable = true;
    package = pkgs.dms-shell.overrideAttrs {
      vendorHash = "sha256-cVUJXgzYMRSM0od1xzDVkMTdxHu3OIQX2bQ8AJbGQ1Q=";
      src = pkgs.fetchFromGitHub {
        owner = "AvengeMedia";
        repo = "DankMaterialShell";
        rev = "9723661c80babc97637319d312eeeb2a3e53f8a7";
        hash = "sha256-3/8DjcoLrqWrJR8QyyzvsFOeej4V5JIq4kMYQF0vccs=";
      };
    };
    systemd.enable = true;
    systemd.restartIfChanged = true;
  };

  # Disable gnome keyring so that Chromium is not showing a popup
  # services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Additional desktop packages
  environment.systemPackages = with pkgs; [
    # Niri
    wl-clipboard
    xwayland-satellite
    swaylock
    rofi
  ];

  # Environment variables
  environment.variables = {
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
        interface = "wlp194s0";
        format = "{ifname}";
        format-wifi = "{essid} ({signalStrength}%)";
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
      package = pkgs.rofi;
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
