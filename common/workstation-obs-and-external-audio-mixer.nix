{ inputs, lib, pkgs, ... }: {
  imports = [
    ./base-config.nix
    ./audio-config.nix
    ./obs
    ./qpwgraph
    ./macropads/numpad.nix
    ./firefox.nix
  ];

  mixos.qpwgraph.patchbay = "obs-audio";
}
