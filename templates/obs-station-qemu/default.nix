{ inputs, lib, pkgs, ... }: {
  imports = [
    ./dev-mapping.nix

    ../../common/platforms/x86_64-virtio-qemu-img.nix
    ../../common/networking-dhcp.nix

    ../../common/workstation-obs-and-external-audio-mixer.nix
    ../../common/assets/assets-openfest.nix
  ];
}
