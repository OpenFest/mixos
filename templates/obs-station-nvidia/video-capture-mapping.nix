{ config, lib, pkgs, ... }:
let
  videoCaptureMap = {
    "pci-0000:03:00.0-usbv3-0:1:1.0" = { name = "video-lecturer"; };
    "pci-0000:03:00.0-usbv3-0:2:1.0" = { name = "video-overview"; };
    "pci-0000:03:00.0-usbv3-0:3:1.0" = { name = "video-closeup"; };
  };

  audioDevMap = {
    "pci-0000:03:00.0-usb-0:1:1.2" = {
      name = "capture-lecturer";
      enabled = true;
    };
    "pci-0000:03:00.0-usb-0:2:1.2" = {
      name = "capture-overview";
      enabled = true;
    };
  };

  makeV4LNameRule = path: data: ''
    KERNEL=="video*", \
    ENV{ID_PATH_WITH_USB_REVISION}=="${path}", \
    SYMLINK+="${data.name}"
  '';
  makeV4LNameRules = linkMap: lib.mapAttrsToList makeV4LNameRule linkMap;
  makeV4LNameRuleStr = linkMap:
    builtins.concatStringsSep "\n" (makeV4LNameRules linkMap);

  makeWireplumberMatcher = devpath: data: {
    matches = [{ "device.bus-path" = devpath; }];
    actions = {
      update-props = {
        "device.profile" = "pro-audio";
        "device.description" = data.name;
        "device.disabled" = false;
      };
    };
  };
  makeWireplumberCfg = devMap: lib.mapAttrsToList makeWireplumberMatcher devMap;
in {
  services.udev.extraRules = makeV4LNameRuleStr videoCaptureMap;
  services.pipewire.wireplumber.extraConfig = {
    "50-disable-devices-by-default" = {
      "monitor.alsa.rules" = [{
        matches = [{ "device.api" = "alsa"; }];
        actions = { update-props = { "device.disabled" = true; }; };
      }];
    };

    "51-capture-mapping" = {
      "monitor.alsa.rules" = makeWireplumberCfg audioDevMap;
    };
  };
}
