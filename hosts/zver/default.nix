{ lib, flake, ... }: let
  hostname = "zver";
in {
  system = "x86_64-linux";
  deployment = {
    ssh = "root@${hostname}";
  };
  imageBuilder = "raw";
  modules = [
    (import ../../common/raw-efi.nix)
    (import ../../common/nvidia.nix)
    ((import ../../common/base-config.nix) { inherit flake lib; })
    ((import ../../common/networking-dhcp.nix) {
      inherit flake lib;
      config = {
        inherit hostname;
        firewall = {
          allowedTCPPorts = [22];
        };
      };
    })

    ({ pkgs, ... }: rec {
      programs.niri.enable = true;

      environment.systemPackages = [
        pkgs.alacritty
        pkgs.fuzzel
      ];
    })
  ];
}
