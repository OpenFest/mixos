{ lib, pkgs, ... }: {
  imports = [ ../../common/dev-mapper.nix ];

  mixos.videoOutputs = {
    main = "DP-1";
    multiview = "DP-2";
    projector = "HDMI-A-1";
  };

  mixos.macro-keyboards.numpad.match = "145f:0239";

  mixos.devMap = {
    videoCapture.by-path = {
      "pci-0000:05:00.0-usbv3-0:1:1.0" = { name = "video-lecturer"; };
      "pci-0000:05:00.0-usbv3-0:2:1.0" = { name = "video-overview"; };
      "pci-0000:05:00.0-usbv3-0:3:1.0" = { name = "video-closeup"; };
      "pci-0000:05:00.0-usbv3-0:4:1.0" = { name = "video-audience"; };
    };

    audio.by-path = {
      "pci-0000:05:00.0-usb-0:1:1.2" = { name = "capture-lecturer"; };
      "pci-0000:05:00.0-usb-0:2:1.2" = { name = "capture-overview"; };
    };

    audio.by-name = {
      "~alsa_card.usb-FOSDEM_Audio_Board_" = { name = "out-streamcam"; };
    };
  };
}
