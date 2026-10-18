{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../common/platforms/aarch64-rpi-bootdisk.nix
    ../../common/networking-dhcp.nix
    ../../common/video-player.nix
  ];
}
