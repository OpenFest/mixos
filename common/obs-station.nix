{ config, lib, pkgs, ... }: {
  imports = [
    ./video-capture-mapping.nix
  ];

  environment.systemPackages = [
    # video shit
    pkgs.obs-studio
    pkgs.obs-studio-plugins.advanced-scene-switcher
    pkgs.guvcview

    # gui shit
    pkgs.firefox
    pkgs.tigervnc
    pkgs.alacritty
    pkgs.fuzzel
  ];

  services.displayManager = {
    defaultSession = "sway";
    autoLogin.enable = true;
    autoLogin.user = "human";
    sddm = {
      enable = true;
      wayland = {
        enable = true;
      };
    };
  };

  programs.sway = let
    swayData = ((import ../configs/sway) { inherit pkgs lib; });
  in {
    enable = true;
    extraOptions = [
      "--unsupported-gpu" # my next GPU will not be nvidia
      "--config" "${swayData.packages.sway-user-data}/config"
    ];
    extraSessionCommands = ''
      {
        echo "sourcing ${swayData.packages.sway-session-script}/bin/sway-session-script"
        source "${swayData.packages.sway-session-script}/bin/sway-session-script"
      } &> /tmp/session_log
    '';
  };

  xdg.portal = {
    enable = true;
    # config = {
    #   common = {
    #     default = [
    #       "gtk"
    #     ];
    #   };
    # };
    wlr = {
      enable = true;
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
  };

  services.xserver = {
    enable = false;
  };

  services.pipewire.extraConfig.pipewire = {
    "55-obs-monitor-sink" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "media.class" = "Audio/Sink";
            "node.name" = "obs_monitor";
            "node.nick" = "obsMonitor";
            "node.description" = "OBS Monitor";
            "audio.position" = "[ FL FR ]";
          };
        }
      ];
    };
  };
}
