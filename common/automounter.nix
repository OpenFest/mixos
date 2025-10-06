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

  makeMountScript = { label, mountpoint, owner }:
    let
      name = "mount-${label}";
      script = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [ pkgs.systemd pkgs.coreutils ];
        text = ''
          if [[ -d "${mountpoint}" ]] && find "${mountpoint}" -mindepth 1 -maxdepth 1 | read -r; then
            # mountpoint exists but is an empty dir
            rmdir "${mountpoint}"
          fi
          if [[ -e "${mountpoint}" ]]; then
            # mountpoint exists and is nonempty
            mv -v "${mountpoint}" "${mountpoint}.$(date +'%Y%m%d%H%M%S')"
          fi

          opts=(
            --no-block --automount=yes
            --collect --options=X-mount.mkdir
          )

          owner="${owner}"
          if [[ -n "$owner" ]]; then
            opts+=(--owner "$owner")
          fi

          systemd-mount "''${opts[@]}" "$DEVNAME" "${mountpoint}"
        '';
      };
    in "${script}/bin/${name}";
  makeUmountScript = { label, mountpoint, ... }:
    let
      name = "mount-${label}";
      script = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [ pkgs.systemd pkgs.coreutils ];
        text = ''
          systemd-umount "$DEVNAME" "${mountpoint}"
          rmdir "${mountpoint}"
        '';
      };
    in "${script}/bin/${name}";
in {
  options.mixos.automount = {
    by-label = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          label = lib.mkOption {
            type = lib.types.str;
            description = "Label to match filesystem of device by";
          };
          owner = lib.mkOption {
            type = lib.types.str;
            description = "Username to chown device to";
            default = "";
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
