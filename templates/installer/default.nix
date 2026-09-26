{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../common/platforms/x86_64-efi-bootdisk.nix

    ./installer.nix
  ];
}
