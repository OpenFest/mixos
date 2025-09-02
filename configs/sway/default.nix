{ pkgs, lib, ... }:
{
  packages = rec {
    sway-user-data = pkgs.stdenvNoCC.mkDerivation rec {
      name = "sway-user-data";
      meta.description = "User configuration and files for Sway";
      src = ./.;
      buildInputs = [
        pkgs.coreutils
        pkgs.pkg-config
        pkgs.makeWrapper
      ];
      phases = ["unpackPhase" "installPhase"];
      installPhase = ''
        mkdir -p $out
        sed "s:@@datadir@@:$out:g" config > $out/config
        cp -vfT wallpaper.jpg $out/wallpaper.jpg
        cp -vfT session.sh $out/session.sh
      '';
    };

    sway-session-script = pkgs.writeShellApplication {
      name = "sway-session-script";

      # note that these will be exposed to the whole sway
      # session, not only during startup
      runtimeInputs = [
        pkgs.coreutils
        pkgs.wayvnc
        sway-user-data
      ];

      text = ''
        # shellcheck disable=SC1091
        source ${sway-user-data}/session.sh
      '';
    };
  };
}
