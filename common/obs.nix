{ lib, pkgs, ... }:
let
  obsConfig = (import ../configs/obs) { inherit pkgs lib; };
in {
  users.users.human.packages = [
    # video shit
    pkgs.obs-studio
    pkgs.obs-studio-plugins.advanced-scene-switcher
    pkgs.guvcview

    obsConfig.obs-config-reset
  ];

  systemd.services.obs-config-create = {
    enable = true;
    description = "create obs config dir if it does not exist";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${obsConfig.obs-config-reset}/bin/obs-config-reset -n";
      User = "human";
      Group = "human";
    };
    wantedBy = [ "multi-user.target" ];
  };

  home-manager.users.human = {
    imports = [ ./gui-sway.nix ];
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
