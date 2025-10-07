{ ... }:
let
  hostnames = [ "player-01" "player-02" "player-03" ];
  mkHost = hostname: rec {
    inherit hostname;
    system = "aarch64-linux";
    image = { format = "sdImage"; };
    moduleArgs = {
      inherit hostname;
      videoPlayerTarget = "https://rnd.qtrp.org/test_videos/cows.mp4";
    };
  };
in map mkHost hostnames
