{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ../../common/raw-efi.nix
    ../../common/base-config.nix
    ../../common/audio-config.nix
  ];
}
