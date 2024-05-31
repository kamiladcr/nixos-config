{ config, pkgs, lib,  ... }:

let
  # Defining a variable with a list of R packages
  r-packages = with pkgs.rPackages; [
    abind     # multi dimentional arrays
    devtools  # developing r packages
    dplyr     # data manipulation
    forcats   # categorical variables
    ggmap     # maps
    ggplot2   # visualisations
    httpgd    # running server
    httr      # APIs (superseded)
    httr2     # APIs
    osmdata   # fetching data from OSM
    purrr     # functional
    rayrender # 3d
    rayshader # 3d
    readr     # reading rectangular
    sf        # spatial
    stars     # raster
    stringr   # strings
    styler    # r
    tibble    # nice
    tidyr     # data
    tidyverse # ihateit
    tmap      # maps
  ];

  # This is an example of how nix can download something from a github
  # repository.
  poetry2nix-source = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "3c92540611f42d3fb2d0d084a6c694cd6544b609";
    sha256 = "sha256:1jfrangw0xb5b8sdkimc550p3m98zhpb1fayahnr7crg74as4qyq";
  };

  # poetr2nix is a nice project that allow to extend nix
  # configurations with poetry. Note that python packages are defined
  # in a separate file (pyproject.toml). To add a new dependency add
  # it to pyproject.toml file and run `poetry lock --no-update`.
  poetry2nix = import poetry2nix-source { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # User configuration
  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.nix_2_3; # Latest nice nix version
  nix.settings.trusted-users = [ "kamiladcr" ];
  # nix.settings.max-jobs = "auto";
  # nix.settings. = [ "kamiladcr" ];
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

  # guest additions for virtual box
  virtualisation.virtualbox.guest.enable = true;

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
    flameshot
    pandoc
    ispell

    vscode

    poetry
    pyright

    # This function creates python with installed packages defined in
    # your poetry project.
    (poetry2nix.mkPoetryEnv {
      pyproject = ./pyproject.toml;
      poetrylock = ./poetry.lock;
      # Needed otherwise nix tries to build it from source
      preferWheels = true;
      overrides = [
        (self: super: {
          packaging = pkgs.python3Packages.packaging;
          numba = super.numba.overridePythonAttrs (old: {
            nativeBuildInputs = [ pkgs.tbb ];
          });
          pyjstat = super.pyjstat.overridePythonAttrs (old: {
            buildInputs = [ super.setuptools ];
          });
          cykhash = super.cykhash.overridePythonAttrs (old: {
            buildInputs = [ super.setuptools super.cython ];
          });
          pyrobuf = super.pyrobuf.overridePythonAttrs (old: {
            buildInputs = [ super.setuptools super.pytest-runner ];
          });
          spint = super.spint.overridePythonAttrs (old: {
            buildInputs = [ super.setuptools ];
          });
          spvcm = super.spvcm.overridePythonAttrs (old: {
            buildInputs = [ super.setuptools ];
          });
        })
      ];
    })

    (rWrapper.override { packages = r-packages; })
    (rstudioWrapper.override { packages = r-packages; })
  ];
}
