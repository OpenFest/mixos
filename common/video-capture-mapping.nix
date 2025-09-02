{ config, lib, pkgs, ... }: let
  pathNameMap = {
    "pci-0000:03:00.0-usbv3-0:2:1.0" = "video-overview";
  };

  makeRule = path: name:
    ''
      KERNEL=="video*", \
      ENV{ID_PATH_WITH_USB_REVISION}=="${path}", \
      SYMLINK+="${name}"
    '';
  makeRules = linkMap: lib.mapAttrsToList makeRule linkMap;
  makeRuleStr = linkMap: builtins.concatStringsSep "\n" (makeRules linkMap);
in {
  services.udev.extraRules = makeRuleStr pathNameMap;
}
