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
      find . -type f | sort | xargs cat | sha256sum | cut -d ' ' -f 1 > $out/obs-studio/.version
    '';
  };
  obs-config-reset = pkgs.writeShellApplication {
    name = "obs-config-reset";
    runtimeInputs = [
      pkgs.rsync
      pkgs.procps
    ];
    text = ''
      set -euo pipefail

      if [[ $# -ge 1 ]]; then
        if [[ "$1" == "-n" ]]; then
          if [[ -d "$HOME/.config/obs-studio" ]] && cmp ${configdir}/obs-studio/.version "$HOME/obs-studio/.version"; then
            exit 0
          fi
        else
          echo "usage: $1 [-n]"
          echo "resets the obs config in $HOME/.config/obs-studio to default values"
          echo "if -n is supplied, does not touch the directory if it is already present"
          exit 1
        fi
      fi

      pkill '.obs-wrapped' || true && echo 'killed obs because it was running'

      mkdir -p "$HOME/.config"
      rsync -rva \
        --chown="$USER" \
        --chmod=D755,F644 \
        --delete \
        ${configdir}/obs-studio/ "$HOME/.config/obs-studio/"
    '';
  };
in { inherit configdir obs-config-reset; }
