{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ../../common/platforms/aarch64-rpi-bootdisk.nix
    ../../common/base-config.nix
    ../../common/audio-config.nix
  ];
}
