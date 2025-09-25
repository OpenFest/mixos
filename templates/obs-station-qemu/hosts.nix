{ ... }: [rec {
  hostname = "hala";
  system = "x86_64-linux";
  image = { format = "qcow-efi"; };
  moduleArgs = { inherit hostname; };
  deploy = {
    hostname = "localhost";
    sshUser = "human";

    remoteBuild = false;
    fastConnection = true;
    sshOpts = [ "-p" "2222" ];
  };
}]
