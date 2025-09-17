{ inputs, lib, pkgs, ... }: {
  imports = [
    ../../common/raw-efi.nix
    ../../common/base-config.nix
    ../../common/audio-config.nix
    ../../common/virtio-initrd.nix
    ../../common/networking-dhcp.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.human = {
    imports = [ ../../common/home-manager.nix ];
    home.stateVersion = "25.05";
  };
}
