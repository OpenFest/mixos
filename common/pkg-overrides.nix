{ nixpkgs, lib, system, ... }:
final: prev: {
  jack_mixer = let
    py = prev.python3Packages;
  in prev.stdenv.mkDerivation {
    pname = "jack_mixer";
    version = "19";
    src = prev.fetchFromGitHub {
      owner = "jack-mixer";
      repo = "jack_mixer";
      rev = "4feeafa496b166dd10a1c2a26b2afe9cb5c41d87";
      hash = "sha256-ElpoDJ8DJI8bV3PEAPhtTxr2JgFcRBQIp1rxpVVSpqI=";
    };
    nativeBuildInputs = [
      prev.meson
    ];
    buildInputs = [
      prev.glib
      prev.pkg-config
      prev.jack2
      prev.python3
      prev.ninja
      py.pycairo
      py.pygobject3
      py.platformdirs
      py.cython
      py.docutils
    ];
  };
}
