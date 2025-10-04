self: super: {
  x-air-edit = super.stdenv.mkDerivation rec {
    pname = "x-air-edit";
    version = "1.8.1";

    src = super.fetchurl {
      url =
        "https://cdn.mediavalet.com/aunsw/musictribe/VX4UkGFjQ0a1DH2Q8zg3sg/_KJ6tGIG7kGVqPxP-OsnLQ/Original/X-AIR-Edit_LINUX_1.8.1.tar.gz";
      sha256 = "sha256-vFy3/iAsGs1IlBSYAX5zTghbPtBfFCUtqVFxfMsFCGY=";
    };

    nativeBuildInputs = with super; [ autoPatchelfHook makeWrapper ];

    buildInputs = with super; [
      stdenv.cc.cc.lib # libstdc++.so.6, libgcc_s.so.1
      alsa-lib # libasound.so.2
      freetype # libfreetype.so.6
      curl # libcurl.so.4
      libGL # libGL.so.1
      # libdl.so.2, libpthread.so.0, libm.so.6, libc.so.6 are provided by stdenv
    ];

    sourceRoot = ".";

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
