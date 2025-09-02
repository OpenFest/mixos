{ config, lib, pkgs, ... }: let
  videoCaptureMap = {
    "pci-0000:03:00.0-usbv3-0:2:1.0" = {
      name = "video-overview";
    };
  };

  audioDevMap = {
    "v4l2_device.pci-0000_03_00.0-usb-0_2_1.0" = {
      name = "capture-overview";
      enabled = true;
    };
  };

  makeV4LNameRule = path: data:
    ''
      KERNEL=="video*", \
      ENV{ID_PATH_WITH_USB_REVISION}=="${path}", \
      SYMLINK+="${data.name}"
    '';
  makeV4LNameRules = linkMap: lib.mapAttrsToList makeV4LNameRule linkMap;
  makeV4LNameRuleStr = linkMap: builtins.concatStringsSep "\n" (makeV4LNameRules linkMap);

  makeWireplumberMatcher = devname: data: {
    matches = [
      {
        "device.name" = devname;
      }
    ];
    actions = {
      update-props = {
        "device.profile" = "pro-audio";
        "device.description" = data.name;
      };
    };
  };
  makeWireplumberCfg = devMap: lib.mapAttrsToList makeWireplumberMatcher devMap;
in {
  services.udev.extraRules = makeV4LNameRuleStr videoCaptureMap;
  services.pipewire.wireplumber.extraConfig."capture-mapping" = {
    "monitor.alsa.rules" = makeWireplumberCfg audioDevMap;
  };
}
