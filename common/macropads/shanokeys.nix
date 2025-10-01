{ pkgs, config, lib, ... }:
let
  shanoconfig = {
    obs = { host = "ws://localhost:4455"; };
    keyboards = config.mixos.macro-keyboards;
  };
in {
  options.mixos.macro-keyboards = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        match = lib.mkOption {
          type = lib.types.str;
          description = "USB VID/PID of keyboard device";
        };
        mappings = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              endpoint = lib.mkOption {
                type = lib.types.str;
                description = "OBS API endpoint name";
              };
              params = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "Object passed to said API endpoint";
              };
            };
          });
          description = "Mapping of keyboard key names to OBS API calls";
        };
      };
    });
    description =
      "Configuration of keyboards that are used for OBS macros instead of input";
  };

  config = {
    users.users.human.packages = [ pkgs.shanokeys pkgs.keyd ];

    systemd.services.keyd.serviceConfig = {
      RestrictAddressFamilies = lib.mkForce "AF_UNIX AF_INET AF_INET6";
      IPAddressAllow = "127.0.0.0/24 ::1/128";
      PrivateNetwork = lib.mkForce "false";
    };

    services.keyd = {
      enable = true;
      keyboards = (lib.mapAttrs (keyboard: props: {
        ids = [ props.match ];
        settings = {
          main = (lib.mapAttrs (key: cmd:
            "command(${pkgs.shanokeys}/bin/shanokeys ${keyboard} ${key})")
            props.mappings);
        };
      })) shanoconfig.keyboards;
    };
    environment.etc."shanokeys.conf".text = builtins.toJSON shanoconfig;
  };
}
