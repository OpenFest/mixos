{
  pkgs,
  lib,
  writeShellApplication,
  nixosConfigurations ? { },
}:
writeShellApplication {
  name = "install-mixos";

  runtimeInputs = with pkgs; [
    coreutils
    nix
    nixos-install-tools
    systemd
  ];

  inheritPath = false;

  text =
    let
      installableConfigurations =
        let
          filtered = lib.filterAttrs (
            _: sys: sys.config.system.build ? destroyFormatMount
          ) nixosConfigurations;
        in
        lib.warnIfNot (filtered != { })
          "mixos-installer: no installable configurations found, none of the nixosConfigurations define a disko layout"
          filtered;

      hostnames = lib.concatMapAttrsStringSep "\n" (name: _: "- ${name}") installableConfigurations;

      branch = name: sys: ''
        ${name})
          diskoScript=${lib.getExe sys.config.system.build.destroyFormatMount}
          system=${sys.config.system.build.toplevel}
          ;;
      '';

      branches = lib.strings.concatMapAttrsStringSep "\n" branch installableConfigurations;
    in
    ''
      if [[ $# -ne 1 ]]; then
        echo "usage: $(basename "$0") <hostname>"
        echo "available hostnames:"
        echo "${hostnames}"
        exit 1
      fi

      if [[ $EUID -ne 0 ]]; then
        echo "this script must be run as root"
        exit 1
      fi

      diskoScript=""
      system=""

      case "$1" in
        ${branches}
        *)
          echo "unknown hostname: $1"
          exit 1
          ;;
      esac

      echo "THIS WILL FUCK SHIT UP"
      read -rp "Please enter 'yolo' in all-caps to proceed: " yolo || yolo="not-yolo"
      if [[ "$yolo" != "YOLO" ]]; then
        echo "no yolo, bailing out"
        exit 1
      fi

      # shellcheck disable=SC2317
      $diskoScript --yes-wipe-all-disks

      # shellcheck disable=SC2317
      nixos-install --option substituters "" --no-root-password --system "$system"

      echo "press enter to reboot"
      read -r || exit 1

      systemctl reboot
    '';
}
