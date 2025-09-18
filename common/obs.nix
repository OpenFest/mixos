{ config, lib, pkgs, ... }: {
  environment.systemPackages = [
    # video shit
    pkgs.obs-studio
    pkgs.obs-studio-plugins.advanced-scene-switcher
    pkgs.guvcview
  ];

  home-manager.users.human.imports = [ ./gui-sway.nix ];

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
