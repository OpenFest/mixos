{ pkgs, config, lib, ... }:
let
  keyboards = config.mixos.macro-keyboards;
  interval = "0.5";

  scriptbody = lib.concatStrings (lib.mapAttrsToList (keyboard: props:
    lib.concatStrings (lib.mapAttrsToList (key: cmd: ''
      echo 'sending ${cmd.endpoint}: ${builtins.toJSON cmd.params} to obs'
      ${pkgs.shanokeys}/bin/shanokeys ${keyboard} ${key} >/dev/null || crashed
      sleep 0.1
      ${pkgs.shanokeys}/bin/shanokeys ${keyboard} kpenter >/dev/null || crashed
      sleep ${interval}
    '') props.mappings)) keyboards);

  crashobs = pkgs.writeShellApplication {
    name = "crashobs";
    meta.description =
      "script for stress-testing obs on a barrage of clicks of the macropad";
    runtimeInputs = [ pkgs.shanokeys ];

    text = ''

      crashed() {
          echo "obs crashed"
          exit 127
      }

      while true; do
      ${scriptbody}
      done
    '';
  };
in { config = { users.users.human.packages = [ crashobs ]; }; }
