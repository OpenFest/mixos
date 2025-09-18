{ pkgs, lib, ... }:
let
  configdir = pkgs.stdenvNoCC.mkDerivation rec {
    name = "sway-user-data";
    meta.description = "obs config directory";
    src = ./obs-studio;
    buildInputs = [ pkgs.coreutils pkgs.rsync ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p $out
      rsync -rva ./ $out/obs-studio/
    '';
  };
  obs-config-reset = pkgs.writeShellApplication {
    name = "obs-config-reset";
    runtimeInputs = [
      pkgs.rsync
    ];
    text = ''
      set -euo pipefail

      if [[ $# -ge 1 ]]; then
        if [[ "$1" == "-n" ]]; then
          if [[ -d "$HOME/.config/obs-studio" ]]; then
            exit 0
          fi
        else
          echo "usage: $1 [-n]"
          echo "resets the obs config in $HOME/.config/obs-studio to default values"
          echo "if -n is supplied, does not touch the directory if it is already present"
          exit 1
        fi
      fi

      mkdir -p "$HOME/.config"
      rsync -rva --delete ${configdir}/obs-studio/ "$HOME/.config/obs-studio/"
    '';
  };
in { inherit configdir obs-config-reset; }
