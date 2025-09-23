{ pkgs, lib, ... }:
let
  growScript = pkgs.writeShellApplication {
    name = "grow-root-once";
    runtimeInputs = [
      pkgs.rsync
      pkgs.cloud-utils
      pkgs.e2fsprogs
      pkgs.btrfs-progs
      pkgs.xfsprogs
      pkgs.util-linux
    ];
    text = ''
      set -euo pipefail

      DONE_FLAG="/var/lib/grow-root.done"
      if [ -e "$DONE_FLAG" ]; then
        echo "grow-root: already done"
        exit 0
      fi

      # Determine current root device (e.g. /dev/nvme0n1p2 or /dev/sda2)
      ROOT_DEV="$(readlink -f "$(findmnt -no SOURCE /)")"
      ROOT_BASENAME="$(basename "$ROOT_DEV")"
      DISK="/dev/$(lsblk -no pkname "$ROOT_DEV")"
      PARTNUM="$(cat /sys/class/block/"$ROOT_BASENAME"/partition)"

      echo "grow-root: root=$ROOT_DEV disk=$DISK part=$PARTNUM"

      ${pkgs.cloud-utils}/bin/growpart "$DISK" "$PARTNUM" || true

      # Resize the filesystem online
      FSTYPE="$(blkid -o value -s TYPE "$ROOT_DEV")"
      case "$FSTYPE" in
        ext4)
          ${pkgs.e2fsprogs}/bin/resize2fs "$ROOT_DEV"
          ;;
        btrfs)
          ${pkgs.btrfs-progs}/bin/btrfs filesystem resize max /
          ;;
        xfs)
          # xfs grows online to full partition with xfs_growfs
          ${pkgs.xfsprogs}/bin/xfs_growfs /
          ;;
        *)
          echo "grow-root: unsupported fs '$FSTYPE' (skipping resize)"
          ;;
      esac

      mkdir -p "$(dirname "$DONE_FLAG")"
      date > "$DONE_FLAG"
      echo "grow-root: done"
    '';
  };
in {
  systemd.services."grow-root-once" = {
    description =
      "Grow root partition and filesystem to full disk (first boot only)";
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "local-fs.target" "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${growScript}/bin/grow-root-once";
      RemainAfterExit = true;
    };
  };
}

