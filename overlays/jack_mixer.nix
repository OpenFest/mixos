self: super: {
  jack_mixer = let py = super.python3Packages;
  in super.stdenv.mkDerivation {
    pname = "jack_mixer";
    version = "19";
    src = super.fetchFromGitHub {
      # owner = "jack-mixer";
      owner = "dexterlb";
      repo = "jack_mixer";
      rev = "64a26f58e08dc6088561dd4b290ca7ca02d25bce";
      hash = "sha256-9SzhpYrxGUK1L2U3aCuzAnEKLzSXTF+3/yJRrdnz7/g=";
    };
    preConfigure = ''
      mesonFlagsArray+=(-Draysessiondir=$prefix/etc/xdg/raysession/client_templates/35_jackmixer)
    '';
    nativeBuildInputs = [ super.meson ];
    preInstall = ''
      patchShebangs --build /build/source/meson_postinstall.py

      # no need to update gtk icon cache during packaging...
      sed -i 's/gtk-update-icon-cache/true/g' /build/source/meson_postinstall.py
    '';
    # TODO: patch python binaries to refer to proper site-packages dir...
    buildInputs = [
      super.glib
      super.pkg-config
      super.jack2
      super.python3
      super.ninja
      py.pycairo
      py.pygobject3
      py.platformdirs
      py.cython
      py.docutils
    ];
  };
}
