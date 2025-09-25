{ modulesPath, lib, pkgs, ... }: {
  imports =
    [
      <nixos-hardware/raspberry-pi/4> # fixme: figure out how to use flake for nixos-hardware
      "${toString modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };
  console.enable = false;
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
}
