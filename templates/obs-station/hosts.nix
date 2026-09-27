{ ... }: [
  rec {
    hostname = "lamya";
    system = "x86_64-linux";
    # image = {
    #   format = "raw";
    # };
    moduleArgs = {
      inherit hostname;
      streamInfo = {
        url = "rtmp://strm.ludost.net/st";
        key = "hall-a";
      };
    };
    deploy = {
      # hostname = "${hostname}.video.openfest.eu";
      hostname = "172.31.190.205";
      sshUser = "human";

      remoteBuild = false;
      fastConnection = true;
    };
  }
]
