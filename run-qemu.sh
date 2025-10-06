#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

QEMU_DIR="${QEMU_DIR:-}"
if [ -z "${QEMU_DIR}" ]; then
  QEMU_DIR="${SCRIPT_DIR}/qemu"
fi
if [ ! -d "$QEMU_DIR" ]; then
  mkdir -p "$QEMU_DIR"
fi

OVMF_DIR="${QEMU_DIR}/ovmf"
if [ ! -d "$OVMF_DIR" ]; then
  mkdir -p "$OVMF_DIR"
fi

if [ ! -d "${SCRIPT_DIR}/result-fd" ]; then
  echo "Please run 'nix build nixpkgs#OVMF.fd' first"
  exit 1
fi

if [ ! -f "${SCRIPT_DIR}/result/nixos.qcow2" ]; then
  echo "Please build the nixos image first"
  echo "ex: nix build .#packages.x86_64-linux.hala"
  exit 1
fi

cp --reflink=auto -r "${SCRIPT_DIR}/result-fd/FV/OVMF_CODE.fd" "$OVMF_DIR/OVMF_CODE.fd"
cp --reflink=auto -r "${SCRIPT_DIR}/result-fd/FV/OVMF_VARS.fd" "$OVMF_DIR/OVMF_VARS.fd"
cp --reflink=auto -r "${SCRIPT_DIR}/result/nixos.qcow2" "$QEMU_DIR/nixos.qcow2"

sudo chown -R ${USER}:users "$QEMU_DIR"
sudo chmod -R 0766 "$QEMU_DIR"

IMG=${QEMU_DIR}/nixos.qcow2
OVMF_CODE=${OVMF_DIR}/OVMF_CODE.fd
OVMF_VARS=${OVMF_DIR}/OVMF_VARS.fd

opts=(
  -enable-kvm -cpu host -smp 4 -m 4096
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE"
  -drive if=pflash,format=raw,file=$OVMF_VARS
  -drive file="$IMG",if=virtio,format=qcow2
  -device virtio-net-pci,netdev=n0
  -serial mon:stdio
  -netdev user,id=n0,hostfwd=tcp::2222-:22
)

if [[ -v QEMU_NO_VGA ]]; then
  opts+=(
    -vnc :4
  )
else
  opts+=(
    -display gtk -device virtio-vga
  )
fi

qemu-system-x86_64 "${opts[@]}"
