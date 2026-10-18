self: super: {
  x-air-edit = super.stdenv.mkDerivation rec {
    pname = "x-air-edit";
    version = "1.8.1";

    src = super.fetchurl {
      url = "https://cdn-media.empowertribe.com/4240ddc8835149e486922840e9379af0/X-AIR-Edit_LINUX_${version}.tar.gz";
      sha256 = "sha256-vFy3/iAsGs1IlBSYAX5zTghbPtBfFCUtqVFxfMsFCGY=";
    };

    nativeBuildInputs = with super; [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with super; [
      stdenv.cc.cc.lib # libstdc++.so.6, libgcc_s.so.1
      alsa-lib # libasound.so.2
      freetype # libfreetype.so.6
      curl # libcurl.so.4
      libGL # libGL.so.1
      # libdl.so.2, libpthread.so.0, libm.so.6, libc.so.6 are provided by stdenv
    ];

    # The tarball has no common top-level directory, so it can't use the
    # default sourceRoot auto-detection. sourceRoot = "." would make the
    # generic unpackPhase chmod the whole build directory recursively,
    # which fails if the build sandbox places its own files there. Extract
    # into a dedicated subdirectory instead; nixpkgs' runPhase cds into
    # sourceRoot for us once unpackPhase returns, so don't cd here too.
    unpackPhase = ''
      runHook preUnpack

      mkdir x-air-edit-src
      tar xf "$src" -C x-air-edit-src

      runHook postUnpack
    '';

    sourceRoot = "x-air-edit-src";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/opt/x-air-edit

      # Copy all files to the installation directory
      cp -r * $out/opt/x-air-edit/

      # Make the binary executable
      chmod +x $out/opt/x-air-edit/X-AIR-Edit

      # Create a wrapper script
      makeWrapper $out/opt/x-air-edit/X-AIR-Edit $out/bin/x-air-edit \
        --prefix LD_LIBRARY_PATH : "${super.lib.makeLibraryPath buildInputs}"

      runHook postInstall
    '';

    meta = with super.lib; {
      description = "X-AIR-Edit mixing software for Behringer X-AIR series";
      homepage = "https://www.behringer.com/";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
}
