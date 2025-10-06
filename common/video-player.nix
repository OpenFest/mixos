{ inputs, lib, pkgs, ... }: {
  imports = [ ./base-config.nix ./audio-config.nix ./caged-mpv.nix ];
}
