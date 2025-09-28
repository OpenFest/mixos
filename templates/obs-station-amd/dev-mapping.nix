{ lib, pkgs, ... }: {
  imports = [ ../../common/dev-mapper.nix ];

  mixos.videoOutputs = {
    main = "DP-1";
    multiview = "DP-2";
    projector = "HDMI-A-1";
  };

  mixos.devMap = {
    videoCapture = {
      "pci-0000:05:00.0-usbv3-0:1:1.0" = { name = "video-lecturer"; };
      "pci-0000:05:00.0-usbv3-0:2:1.0" = { name = "video-overview"; };
      "pci-0000:05:00.0-usbv3-0:3:1.0" = { name = "video-closeup"; };
    };

    audio = {
      "pci-0000:05:00.0-usb-0:1:1.2" = { name = "capture-lecturer"; };
      "pci-0000:05:00.0-usb-0:2:1.2" = { name = "capture-overview"; };
    };
  };
}
