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
    pkgs.audacity

    pkgs.jack_mixer
  ];

  security.rtkit.enable = true;

  boot.kernelParams = ["threadirqs"];

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
      "context.modules" = [
        {
          name = "libpipewire-module-rt";
          args = {
            "nice.level" = -11;
            "rt.prio" = 19;
          };
        }
      ];
    };
  };

  # expose timers etc. to "audio"
  services.udev.extraRules = ''
    DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
    DEVPATH=="/devices/virtual/misc/hpet", OWNER="root", GROUP="audio", MODE="0660"
  '';

  # set the controls for the heart of the sun
  systemd.tmpfiles.settings."85-rtc-max-freq" = {
    "/sys/class/rtc/rtc0/max_user_freq".w = {
      mode = "0644";
      user = "root";
      group = "root";
      argument = "2048";
    };
    "/proc/sys/dev/hpet/max-user-freq".w = {
      mode = "0644";
      user = "root";
      group = "root";
      argument = "4096";
    };
  };

  # allow all processes to do dangerous stuff
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "8192000";
    }
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
  ];
}
