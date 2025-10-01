{ inputs, lib, pkgs, ... }: {
  imports = [ ./base-config.nix ./audio-config.nix ./obs ./qpwgraph ];

  mixos.qpwgraph.patchbay = "obs-audio";
}
