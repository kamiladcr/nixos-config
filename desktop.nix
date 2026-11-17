{ pkgs, lib, config, ... }:

{
  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable compatibility with older applications
  programs.xwayland.enable = true;

  # Windows
  programs.niri.enable = true;

  # https://codeberg.org/ezemtsov/ewm
  programs.ewm.enable = true;

  # Battery status over D-Bus, needed for the dms-shell battery widget
  services.upower.enable = true;

  # Shell (top panel)
  programs.dms-shell = {
    enable = true;
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

    # Screenshot: interactive area select, copies to clipboard
    (writeShellScriptBin "screenshot" ''
      ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" - | ${wl-clipboard}/bin/wl-copy
    '')
  ];

  # Environment variables
  environment.variables = {
    # Use emacs by default
    EDITOR = "emacsclient";
  };

  # Home-directory configuration
  home-manager.useGlobalPkgs = true;
  home-manager.users.kamiladcr = {
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
