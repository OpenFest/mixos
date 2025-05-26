{ pkgs, config, ... }: let
  audio_quant = 32;   # start from 32, go higher if it causes problems
in rec {
  environment.systemPackages = [
    pkgs.qpwgraph
    pkgs.pwvucontrol
    pkgs.pavucontrol
    pkgs.jackmix
    pkgs.lsp-plugins
    pkgs.guitarix   # absolutely essential lol
    pkgs.pulseaudio # for pactl, fixme

    pkgs.jack_mixer
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = audio_quant;
        "default.clock.min-quantum" = audio_quant;
        "default.clock.max-quantum" = audio_quant;
      };
    };
  };

  # allow all processes to do dangerous stuff
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "memlock";
      value = "8192000";
    }
    {
      domain = "*";
      type = "-";
      item = "rtprio";
      value = "95";
    }
  ];
}
