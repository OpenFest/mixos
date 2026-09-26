{ pkgs, nixosConfigurations, ... }:
let
  mixos-installer = pkgs.callPackage ../../packages/mixos-installer.nix {
    inherit nixosConfigurations;
  };
in
{
  imports = [
    ../../common/base-config.nix
  ];

  users.motd = "use 'sudo mixos-install <hostname>' to flash this machine";

  environment.systemPackages = [
    mixos-installer
  ];
}
