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
        key = "sofia";
     };
    };
    deploy = {
      hostname = "lamya.video.openfest.org";
      sshUser = "human";
    };
  }
]
