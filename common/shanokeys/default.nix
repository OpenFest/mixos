{ pkgs, ... }:
with pkgs.python3Packages;
let
  shanoconfig = {
    obs = { host = "ws://localhost:4455"; };
    keyboards = {
      numpad = {
        match = "c0f4:08c0";
        mappings = {
          kp1 = {
            endpoint = "SetCurrentPreviewScene";
            params = { sceneName = "Intermezzo"; };
          };
          kp2 = {
            endpoint = "SetCurrentPreviewScene";
            params = { sceneName = "Fullscreen closeup"; };
          };
          kp3 = {
            endpoint = "SetCurrentPreviewScene";
            params = { sceneName = "Fullscreen audience"; };
          };
          kp4 = {
            endpoint = "SetCurrentPreviewScene";
            params = { sceneName = "Fullscreen overview"; };
          };
          kp5 = {
            endpoint = "SetCurrentPreviewScene";
            params = { sceneName = "Fullscreen slides"; };
          };
          kp6 = {
            endpoint = "SetCurrentPreviewScene";
            params = { sceneName = "Break"; };
          };
          kpenter = { endpoint = "TriggerStudioModeTransition"; };
        };
      };
    };
  };
  simpleobsws = let
    pname = "simpleobsws";
    version = "1.4.3";
  in buildPythonPackage {
    inherit pname version;
    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-nNH5fkzDmkLP0vXD/9nnhd9ZE8INFz7CWuHCVzvroO0=";
    };
    pyproject = true;
    build-system = [ setuptools ];
    dependencies = [ websockets msgpack ];
  };
  shanokeys = let
    pname = "shanokeys";
    version = "0.0.1";
  in buildPythonApplication {
    inherit pname version;
    src = pkgs.fetchFromGitHub {
      inherit pname version;
      owner = "aastefanov";
      repo = "shanokeys";
      rev = "7d3e8a14732b149651ce3e7f881f3b2b9f8b97a6";
      hash = "sha256-oQWTfsxMJZF/QlrGOShh2KQ0a6mzm2MuwDL+ocw5gLA=";
    };
    pyproject = true;
    build-system = [ setuptools ];

    dependencies = [ pyyaml dataclass-wizard simpleobsws ];

    nativeBuildInputs = [ pythonRelaxDepsHook setuptools setuptools-scm ];
    pythonRelaxDeps = [ ];

  };
in {
  users.users.human.packages = [ shanokeys pkgs.keyd ];

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
        main = (lib.mapAttrs
          (key: cmd: "command(${shanokeys}/bin/shanokeys ${keyboard} ${key})")
          props.mappings);
      };
    })) shanoconfig.keyboards;
  };
  environment.etc."shanokeys.conf".text = builtins.toJSON shanoconfig;
}
