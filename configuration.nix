{ config, pkgs, lib, ... }:

let
  sources = import ./npins/default.nix;
in
{
  imports =
    [
      "${sources.home-manager}/nixos" # Home dotfiles
      ./hardware-configuration.nix
      ./desktop.nix
      "${sources.ewm}/nix/service.nix"
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "oslo";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Life in Oslo
  time.timeZone = "Europe/Oslo";

  # User configuration
  # nix.package = pkgs.nix_2_3; # Latest nice nix version
  nix.settings.trusted-users = [ "kamiladcr" ];
  nix.settings.max-jobs = "auto";

  nix.nixPath = ["nixpkgs=${sources.nixpkgs}:nixos-config=/etc/nixos/configuration.nix"];
  nixpkgs.pkgs = (import sources.nixpkgs {
    config.allowUnfree = lib.mkForce true;
  });

  users.users.kamiladcr = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "demo";
    uid = 1000;
  };

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  # # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Mount USB drives automatically
  services.gvfs.enable = true;

  programs.light.enable = true;

  hardware.bluetooth.enable = true;

  services.onedrive.enable = true;

  services.tailscale.enable = true;

  # Power saving
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT="powersave";
      CPU_SCALING_GOVERNOR_ON_AC="performance";
    };
  };

  # Using fish instead of bash, it offers amazing completion
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Alacritty as default terminal
  environment.sessionVariables.TERMINAL = [ "alacritty" ];

  fonts.packages = with pkgs; [
    iosevka
    lora
    montserrat
  ];

  # git config
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      user.name  = "kamiladcr";
      user.email = "kamila.dzhavatova@gmail.com";
    };
  };

  # Packages to be installed globally
  environment.systemPackages = with pkgs; [
    alacritty
    bottom
    claude-code
    emacs30-pgtk
    emacsPackages.jinx
    enchant
    firefox
    flameshot
    fuzzel
    git
    google-chrome
    gzip
    hunspellDicts.en-us
    hunspellDicts.nb_NO
    hunspellDicts.sv_SE
    ispell
    krita
    libreoffice
    mpv
    nautilus
    nixos-option
    npins
    obsidian
    onedrive
    osmium-tool
    pandoc
    pavucontrol
    pmtiles
    prettierd
    pyright
    qgis
    restream
    ripgrep
    rofi
    telegram-desktop
    tippecanoe
    unzip
    uv
    vlc
    vscode
    xwayland
    xwayland-satellite

    # Python environment - see explanation below
    (pkgs.callPackage ./python.nix {})

    # To make the script available from any folder
    (pkgs.writeShellScriptBin "nixos-switch" (builtins.readFile ./nixos-switch))
  ];

  # Allow using binaries coming from python packages
  programs.nix-ld.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # programs.steam.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
