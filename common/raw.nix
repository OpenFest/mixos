{ config, lib, pkgs, modulesPath, ... }: {

  system.build.raw =
    import "${toString modulesPath}/../lib/make-disk-image.nix" {
      inherit lib config pkgs;
      inherit (config.virtualisation) diskSize;
      format = "raw";
    };
}
