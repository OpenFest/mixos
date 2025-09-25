{ ... }:
let
  hostnames = [ "player-01" "player-02" "player-03" ];
  mkHost = hostname: rec {
    inherit hostname;
    system = "aarch64-linux";
    image = { format = "sd-aarch64"; };
    moduleArgs = {
      inherit hostname;
    };
  };
in map mkHost hostnames
