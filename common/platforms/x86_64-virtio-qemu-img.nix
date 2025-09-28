{ ... }: {
  boot.initrd.availableKernelModules =
    [ "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_console" "virtio_net" ];
  # do not override image settings, use whatever nixos-generators provides
}
