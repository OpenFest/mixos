{ ... }: [
  rec {
    hostname = "hala";
    system = "x86_64-linux";
    image = {
      format = "raw";
    };
    moduleArgs = {
      inherit hostname;
    };
    deploy = {
      hostname = "localhost";
      sshUser = "human";

      remoteBuild = false;
      fastConnection = true;
      sshOpts = [ "-p" "2222" ];
    };
  }
]
