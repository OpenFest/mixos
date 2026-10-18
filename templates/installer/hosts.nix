{ ... }: [
  rec {
    hostname = "mixos-installer";
    system = "x86_64-linux";
    image = {
      format = "raw";
    };
    moduleArgs = {
      inherit hostname;
    };
    deploy = {
      hostname = "172.31.190.205";
      sshUser = "human";

      remoteBuild = false;
      fastConnection = true;
    };
  }
]
