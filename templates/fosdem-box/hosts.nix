{ ... }: let
  fosboxes = ["101" "102" "103"];
  mkFosbox = id:
    rec {
      hostname = "fosbox-${id}";
      system = "x86_64-linux";
      image = {
        format = "raw";
      };
      moduleArgs = {
        inherit hostname;
        fosdemNetworkIP = "172.22.11.${id}";
        fosdemNetworkDomain = "box${id}.video.fosdem.org";
      };
    };
  in
    map mkFosbox fosboxes
