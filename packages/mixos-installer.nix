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
      hostnames = lib.concatMapAttrsStringSep "\n" (name: _: "- ${name}") nixosConfigurations;

      branch = name: sys: ''
        ${name})
          diskoScript=${lib.getExe sys.config.system.build.destroyFormatMount}
          system=${sys.config.system.build.toplevel}
          ;;
      '';

      branches = lib.strings.concatMapAttrsStringSep "\n" branch nixosConfigurations;
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

      reboot
    '';
}
