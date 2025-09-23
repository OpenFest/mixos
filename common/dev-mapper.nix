{ config, lib, pkgs, ... }:
let
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
  makeWireplumberCfg = audioDevMap: {
    "50-disable-devices-by-default" = {
      "monitor.alsa.rules" = [{
        matches = [{ "device.api" = "alsa"; }];
        actions = { update-props = { "device.disabled" = true; }; };
      }];
    };

    "51-capture-mapping" = {
      "monitor.alsa.rules" =
        lib.mapAttrsToList makeWireplumberMatcher audioDevMap;
    };
  };
in {
  options.mixos.devMap = {
    videoCapture = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Logical name assigned to this video capture device.";
          };
        };
      });
      default = { };
      description = ''
        Mapping of video capture device IDs to configuration.
        Keys are device IDs (e.g. "pci-0000:03:00.0-usbv3-0:1:1.0").
        Each entry must specify at least a `name`.
      '';
    };
    audio = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Logical name assigned to this audio device.";
          };
        };
      });
      default = { };
      description = ''
        Mapping of audio device IDs to configuration.
        Keys are device IDs (e.g. "pci-0000:03:00.0-usbv3-0:1:1.0").
        Each entry must specify at least a `name`.
      '';
    };
  };

  config = {
    services.udev.extraRules =
      makeV4LNameRuleStr config.mixos.devMap.videoCapture;
    services.pipewire.wireplumber.extraConfig =
      makeWireplumberCfg config.mixos.devMap.audio;
  };
}
