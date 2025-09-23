{ config, lib, pkgs, ... }: {

  # Enable OpenGL
  hardware.graphics = { enable = true; };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "amdgpu" ];

  # enable amdgpu kernel module
  boot.initrd.kernelModules = [ "amdgpu" ];
}
