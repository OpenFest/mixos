{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./video-capture-mapping.nix

    ../../common/raw-efi.nix
    ../../common/base-config.nix
    ../../common/audio-config.nix
    ../../common/nvidia.nix
    ../../common/grow-root.nix
    ../../common/obs.nix
    ../../common/networking-dhcp.nix
  ];
}
