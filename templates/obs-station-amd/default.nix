{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./dev-mapping.nix

    ../../common/platforms/x86_64-efi-bootdisk.nix
    ../../common/gpu-support/amdgpu.nix
    ../../common/networking-dhcp.nix

    ../../common/workstation-obs-and-external-audio-mixer.nix
  ];
}
