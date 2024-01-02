{ config, pkgs, lib,  ... }:

let
  # Defining a variable with a list of R packages
  r-packages = with pkgs.rPackages; [
    abind # multi dimentional arrays
    devtools # developing r packages
    dplyr # data manipulation
    forcats # categorical variables
    ggmap # maps
    ggplot2 # visualisations
    httr # APIs (superseded)
    httr2 # APIs
    httpgd # running server
    osmdata # fetching data from OSM
    purrr # functional
    rayrender # 3d
    rayshader # 3d
    readr # reading rectangular
    sf # spatial
    stars # raster
    stringr # strings
    styler # r
    tibble # nice
    tidyr # data
    tidyverse # ihateit
    tmap # maps
  ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # User configuration
  nix.package = pkgs.nix_2_3; # Latest nice nix version
  nix.settings.trusted-users = [ "kamiladcr" ];
  users.users.kamiladcr = {
    isNormalUser = true;
    extraGroups = [ "vboxsf" "wheel" ];
    initialPassword = "demo";
    uid = 1000;
  };

  # Using fish instead of bash, it offers amazing completion
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Enable graphical accelleration (needed for 3d)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Desktop environment
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager.lightdm.background = "#000000";
    videoDrivers = [ "virtualbox" "vmware" "cirrus" "vesa" "modesetting" ];
  };

  # Windows onedrive file share
  fileSystems."/mnt/windows" = {
    fsType = "vboxsf";
    device = "N";
    options = [ "rw" ];
  };

  # Life in Oslo
  time.timeZone = "Europe/Oslo";

  # Default terminal is alcritty now (it's great!)
  environment.sessionVariables.TERMINAL = [ "alacritty" ];

  # Packages to be installed globally
  environment.systemPackages = with pkgs; [
    alacritty
    emacs29
    git
    nixos-option

    chromium
    tdesktop
    gnome.nautilus
    gzip
    unzip

    (python3.withPackages (p: with p; [
      pandas
      geopandas
      shapely
      osmnx
      plotly
    ]))

    (rWrapper.override { packages = r-packages; })
    (rstudioWrapper.override { packages = r-packages; })
  ];
}
