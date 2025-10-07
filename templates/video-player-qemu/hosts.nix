{ ... }: [rec {
  hostname = "player-qemu";
  system = "x86_64-linux";
  image = { format = "qcow-efi"; };
  moduleArgs = {
    inherit hostname;
    videoPlayerTarget = "https://rnd.qtrp.org/test_videos/cows.mp4";
  };
}]
