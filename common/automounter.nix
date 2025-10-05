{ config, lib, pkgs, ... }:
let
  makeAutomountLabelRules = rules:
    builtins.concatStringsSep "\n" (map makeAutomountLabelRule rules);

  # thanks to mike for the hint: https://mikejsavage.co.uk/nixos-auto-mounting
  makeAutomountLabelRule = { label, ... }@opts: ''
    SUBSYSTEMS=="usb", SUBSYSTEM=="block", ACTION=="add", \
      ENV{ID_FS_USAGE}=="filesystem", ENV{ID_FS_LABEL}=="${label}", \
      RUN+="${makeMountScript opts}"

    SUBSYSTEMS=="usb", SUBSYSTEM=="block", ACTION=="remove", \
      ENV{ID_FS_USAGE}=="filesystem", ENV{ID_FS_LABEL}=="${label}", \
      RUN+="${makeUmountScript opts}"
  '';

  makeMountScript = { label, mountpoint }:
    pkgs.writeShellApplication {
      name = "mount-${label}";
      runtimeInputs = [ pkgs.systemd pkgs.coreutils ];
      text = ''
        systemd-mount \
          --no-block --automount=yes \
          --collect --options=X-mount.mkdir \
          "$DEVNAME" "${mountpoint}"
      '';
    };
  makeUmountScript = { label, mountpoint }:
    pkgs.writeShellApplication {
      name = "mount-${label}";
      runtimeInputs = [ pkgs.systemd pkgs.coreutils ];
      text = ''
        systemd-umount "$DEVNAME" "${mountpoint}"
        rmdir "${mountpoint}"
      '';
    };
in {
  options.mixos.automount = {
    by-label = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          label = lib.mkOption {
            type = lib.types.str;
            description = "Label to match filesystem of device by";
          };
          mountpoint = lib.mkOption {
            type = lib.types.str;
            description = "Full path to mountpoint";
          };
        };
      });
      default = { };
      description = ''
        Automount filesystems by matching on their labels.
      '';
    };
  };

  config = {
    services.udev.extraRules =
      makeAutomountLabelRules config.mixos.automount.by-label;
  };
}
