{ lib, config, ... }:
{ pkgs, ... }: {
  networking = rec {
    hostName = config.hostname;
    domain = "video.fosdem.org";
    dhcpcd.enable = true;
    hosts = {
      "::1" = [ "${hostName}.${domain}" hostName ];
      "127.0.0.1" = [ "${hostName}.${domain}" hostName ];
    };
    firewall = { allowedTCPPorts = [ 22 ]; } // config.firewall;
    # nameservers = [ "2001:67c:21bc:1e::53" "185.117.82.68" ];
  };
}
