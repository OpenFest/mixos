{ config, pkgs, lib, ... }:
let
  configdir = pkgs.stdenvNoCC.mkDerivation rec {
    name = "qpwgraph-config";
    meta.description = "qpwgraph configuration and patchbays";
    src = ./data;
    buildInputs = [ pkgs.coreutils pkgs.rsync ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p $out
      rsync -rva ./ $out/data/
      find . -type f | sort | xargs cat | sha256sum | cut -d ' ' -f 1 > $out/.version
    '';
  };
  qpwgraph-reset = pkgs.writeShellApplication {
    name = "qpwgraph-reset";
    runtimeInputs = [
      pkgs.rsync
      pkgs.procps
    ];
    text = ''
      set -euo pipefail

      if [[ $# -ge 1 ]]; then
        if [[ "$1" == "-n" ]]; then
          if [[ -d "$HOME/.local/share/patchbays" ]] && cmp ${configdir}/.version "$HOME/.local/share/patchbays/.version"; then
            exit 0
          fi
        else
          echo "usage: $1 [-n]"
          echo "resets the qpwgraph config and patchbay to default values"
          echo "if -n is supplied, does not touch the files if already present"
          exit 1
        fi
      fi

      pkill '^qpwgraph$' || true && echo 'killed qpwgraph because it was running'

      mkdir -p "$HOME/.config/rncbc.org" "$HOME/.local/share/patchbays"
      rsync -rva \
        --chown="$USER" \
        --chmod=D755,F644 \
        ${configdir}/data/qpwgraph.conf "$HOME/.config/rncbc.org/qpwgraph.conf"
      rsync -rva \
        --chown="$USER" \
        --chmod=D755,F644 \
        ${configdir}/data/patchbays/${config.mixos.qpwgraph.patchbay}.qpwgraph "$HOME/.local/share/patchbays/main.qpwgraph"
    '';
  };
in {
  imports = [ ../gui-sway ];

  options.mixos.qpwgraph.patchbay = lib.mkOption {
    type = lib.types.str;
    description = "Name of qpwgraph patchbay that will be used as main patchbay and loaded on startup";
  };

  config = {
    users.users.human.packages = [
      pkgs.qpwgraph
      qpwgraph-reset
    ];

    systemd.services.qpwgraph-init = {
      enable = true;
      description = "create qpwgraph patchbays and config if they don't exist";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${qpwgraph-reset}/bin/qpwgraph-reset -n";
        User = "human";
        Group = "human";
      };
      wantedBy = [ "multi-user.target" ];
    };

    home-manager.users.human = {
      wayland.windowManager.sway.config.startup = [
        { command = "${pkgs.qpwgraph}/bin/qpwgraph"; }
      ];
    };
  };
}
