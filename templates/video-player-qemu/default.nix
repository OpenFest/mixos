{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ../../common/platforms/x86_64-virtio-qemu-img.nix
    ../../common/networking-dhcp.nix
    ../../common/video-player.nix
  ];
}
