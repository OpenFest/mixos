{ lib, hostname, ... }: {
  networking = rec {
    # FIXME: decide if passing the hostname as a module argument is a good idea
    # or should the flake just insert it as `networking.hostName` and be done with it?
    # upside of the current approach is that it is flexible
    # downside is that you have to write this in every single hosts config, and
    # who would want to set the hostname to anything other than the host hostname anyway?
    hostName = hostname;
    domain = "video.fosdem.org";
    dhcpcd.enable = true;
    hosts = {
      "::1" = [ "${hostName}.${domain}" hostName ];
      "127.0.0.1" = [ "${hostName}.${domain}" hostName ];
    };
    firewall = { allowedTCPPorts = [ 22 ]; };
    # nameservers = [ "2001:67c:21bc:1e::53" "185.117.82.68" ];
  };
}
