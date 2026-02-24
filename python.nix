{
  sources ? import ./npins/default.nix,
  pkgs ? import sources.nixpkgs {},
  lib ? pkgs.lib,
}:

let
  sources = import ./npins/default.nix;

  # pyproject-nix is a nice project that allow to extend nix
  # configurations with uv. Note that python packages are defined
  # in a separate file (pyproject.toml).
  pyproject-nix = import sources.pyproject-nix {
    inherit lib;
  };

  # To add a new dependency add it to pyproject.toml file and run `uv lock`.
  uv2nix = import sources.uv2nix {
    inherit lib pyproject-nix;
  };

  pyproject-build-systems = import sources.build-system-pkgs {
    inherit lib pyproject-nix uv2nix;
  };

  # Importing uv lock file
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

  # Configure provisioning through wheel files
  uvOverlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  # Construct package set
  pythonSet = (pkgs.callPackage pyproject-nix.build.packages {
    python = pkgs.python3;
  }).overrideScope (lib.composeManyExtensions [
    # Build system packages
    pyproject-build-systems.default

    # Packages from uv
    uvOverlay

    # Patches for packages that need additional buildInputs
    (self: super: {
      # Fix setuptools missing
      hdbscan = super.hdbscan.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
          self.setuptools
          self.cython
          self.numpy
        ];
      });

      pyjstat = super.pyjstat.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ self.setuptools ];
      });
    })
  ]);

in
pythonSet.mkVirtualEnv "python-env" workspace.deps.all
