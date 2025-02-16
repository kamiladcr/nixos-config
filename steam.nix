{ pkgs, config, ... }:

let
  user = "kamiladcr";
in
{
  # Additional gaming packages
  environment.systemPackages = with pkgs; [
    torzu # Nintendo emulator
    steam-rom-manager # Add Nintendo games to steam
    wineWowPackages.stableFull # For pirated games
    lutris # Launcher for pirated games
  ];

  # Handheld Daemon to control hardware
  services.handheld-daemon = {
    inherit user;
    enable = true;
    ui.enable = true;
  };

  # Let SteamOS know that we're using AMD CPU
  jovian.hardware.has.amd.gpu = true;
  hardware.cpu.amd.updateMicrocode = true;

  # Keep SSD healthy
  services.fstrim.enable = true;

  # Disable everything when leaving desktop
  services.logind.killUserProcesses = true;

  jovian.steam = {
    inherit user;
    enable = true;
    autoStart = true;
    desktopSession = "niri";
  };

  jovian.steamos = {
    useSteamOSConfig = true;
    # Not needed, slows down updates
    enableVendorRadv = false;
    enableMesaPatches = false;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  # Allow steam to install apps
  services.flatpak.enable = true;

  services.displayManager.autoLogin = {
    inherit user;
    enable = true;
  };

  jovian.decky-loader = {
    inherit user;
    enable = true;
    stateDir = "/home/kamiladcr/.local/share/decky";
  };

  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    extest.enable = false;
    remotePlay.openFirewall = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  # This extension enables TDP control
  # TODO: remove when https://github.com/NixOS/nixpkgs/pull/347279 is merged
  nixpkgs.overlays = [
    (self: super: {
      handheld-daemon = super.handheld-daemon.overridePythonAttrs (o: {
        dependencies = with super; with python3Packages; o.dependencies ++ [
          (buildPythonPackage rec {
            pname = "adjustor";
            version = "3.6.1";
            pyproject = true;
            src = fetchFromGitHub {
              owner = "hhd-dev";
              repo = "adjustor";
              rev = "refs/tags/v${version}";
              hash = "sha256-A5IdwuhsK9umMtsUR7CpREGxbTYuJNPV4MT+6wqcWT8=";
            };
            postPatch = ''
              substituteInPlace src/adjustor/core/acpi.py \
                --replace-fail '"modprobe"' '"${lib.getExe' kmod "modprobe"}"'
              substituteInPlace src/adjustor/fuse/utils.py \
                --replace-fail 'f"mount' 'f"${lib.getExe' util-linux "mount"}'
            '';
            doCheck = false;
            build-system = [ setuptools ];
            dependencies = [
              rich
              pyroute2
              fuse
              pygobject3
              dbus-python
              kmod
            ];
          })
        ];
      });
    })
  ];
}
