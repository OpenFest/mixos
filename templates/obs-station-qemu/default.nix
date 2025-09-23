{ inputs, lib, pkgs, ... }: {
  imports = [
    ./dev-mapping.nix

    ../../common/raw-efi.nix
    ../../common/virtio-initrd.nix
    ../../common/networking-dhcp.nix

    ../../common/workstation-obs-and-external-audio-mixer.nix
  ];
}
