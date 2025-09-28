{ inputs, lib, pkgs, ... }: {
  imports =
    [ ./base-config.nix ./audio-config.nix ./obs ./qpwgraph ./shanokeys ];

  mixos.qpwgraph.patchbay = "obs-audio";
}
