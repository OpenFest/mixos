{ lib, pkgs, ... }:
let
  configdir = pkgs.stdenvNoCC.mkDerivation rec {
    name = "obs-config-dir";
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
    runtimeInputs = [ pkgs.rsync pkgs.procps ];
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
in {
  imports = [ ../gui-sway ];

  users.users.human.packages = [
    # video shit
    pkgs.guvcview

    obs-config-reset
  ];

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.advanced-scene-switcher ];
  };

  systemd.services.obs-config-create = {
    enable = true;
    description = "create obs config dir if it does not exist";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${obs-config-reset}/bin/obs-config-reset -n";
      User = "human";
      Group = "human";
    };
    wantedBy = [ "multi-user.target" ];
  };

  home-manager.users.human = {
    wayland.windowManager.sway.config.startup = [{ command = "obs"; }];
  };

  services.pipewire.extraConfig.pipewire = {
    "55-obs-monitor-sink" = {
      "context.objects" = [{
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "media.class" = "Audio/Sink";
          "node.name" = "obs_monitor";
          "node.nick" = "obsMonitor";
          "node.description" = "OBS Monitor";
          "audio.position" = "[ FL FR ]";
        };
      }];
    };
  };
}
