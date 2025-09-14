{ nixpkgs, lib, system, ... }:
final: prev: {
  jack_mixer = let py = prev.python3Packages;
  in prev.stdenv.mkDerivation {
    pname = "jack_mixer";
    version = "19";
    src = prev.fetchFromGitHub {
      # owner = "jack-mixer";
      owner = "dexterlb";
      repo = "jack_mixer";
      rev = "64a26f58e08dc6088561dd4b290ca7ca02d25bce";
      hash = "sha256-9SzhpYrxGUK1L2U3aCuzAnEKLzSXTF+3/yJRrdnz7/g=";
    };
    preConfigure = ''
      mesonFlagsArray+=(-Draysessiondir=$prefix/etc/xdg/raysession/client_templates/35_jackmixer)
    '';
    nativeBuildInputs = [ prev.meson ];
    preInstall = ''
      patchShebangs --build /build/source/meson_postinstall.py

      # no need to update gtk icon cache during packaging...
      sed -i 's/gtk-update-icon-cache/true/g' /build/source/meson_postinstall.py
    '';
    # TODO: patch python binaries to refer to proper site-packages dir...
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

  obs-studio = prev.obs-studio.overrideAttrs {
    # pipewire support is buggy on wayland compositors like sway
    # and causes obs to hang for 1min on startup
    pipewireSupport = false;

    # enable this only if we start packaging decklink stuff…
    decklinkSupport = false;
  };
}
