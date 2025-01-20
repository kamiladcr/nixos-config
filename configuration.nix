{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./common.nix
      ./go.nix
    ];
}
