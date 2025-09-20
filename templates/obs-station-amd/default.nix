{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./dev-mapping.nix

    ../../common/raw-efi.nix
    ../../common/base-config.nix
    ../../common/audio-config.nix
    ../../common/amdgpu.nix
    # ../../common/grow-root.nix
    ../../common/obs.nix
    ../../common/networking-dhcp.nix
  ];
}
