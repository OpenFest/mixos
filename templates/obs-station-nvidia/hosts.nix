{ ... }: [rec {
  hostname = "zver";
  system = "x86_64-linux";
  image = { format = "raw"; };
  moduleArgs = { inherit hostname; };
  deploy = {
    hostname = "${hostname}.pit.protopit.eu";
    sshUser = "human";

    remoteBuild = false;
    fastConnection = true;
  };
}]
