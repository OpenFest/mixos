{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./dev-mapping.nix

    ../../common/raw-efi.nix
    ../../common/amdgpu.nix
    # ../../common/grow-root.nix
    ../../common/networking-dhcp.nix

    ../../common/workstation-obs-and-external-audio-mixer.nix
  ];
}
