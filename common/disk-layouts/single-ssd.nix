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
            size = "64G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          "of-rec" = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              extraArgs = [ "-L" "OF-REC" ];
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
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };
}
