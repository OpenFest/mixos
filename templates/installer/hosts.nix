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
  }
]
