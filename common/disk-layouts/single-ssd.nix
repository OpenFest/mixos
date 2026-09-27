{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices.disk = {
    root = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              mountpoint = "/";
            };
          };
        };
      };
    };
  };

  boot = {
    loader.timeout = lib.mkDefault 0;
    initrd.availableKernelModules = [ "uas" ];
    loader.grub = {
      device = "/dev/sda";
      efiSupport = true;
      # efiInstallAsRemovable = true;
    };
  };
}
