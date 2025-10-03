{ lib, pkgs, ... }: {
  imports = [ ../../common/dev-mapper.nix ];

  mixos.videoOutputs = {
    main = "Virtual-1";
    multiview = "Virtual-2";
    projector = "Virtual-3";
  };

  # FIXME: emulated second keyboard?
  mixos.macro-keyboards.numpad.match = "145f:0239";
}
