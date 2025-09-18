{ inputs, lib, pkgs, ... }: {
  imports = [
    ../../common/raw-efi.nix
    ../../common/base-config.nix
    ../../common/audio-config.nix
    ../../common/virtio-initrd.nix
    ../../common/networking-dhcp.nix
    ../../common/obs.nix
  ];
}
