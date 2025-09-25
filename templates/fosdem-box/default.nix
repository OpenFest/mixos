{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ../../common/platforms/x86_64-efi-bootdisk.nix
    ../../common/base-config.nix
    ../../common/audio-config.nix
  ];
}
