{ modulesPath, lib, ... }: {
  imports =
    [ "${toString modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
}
