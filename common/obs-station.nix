{ config, lib, pkgs, ... }: {

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

  programs.sway = {
    enable = true;
    extraOptions = [
      "--unsupported-gpu" # my next GPU will not be nvidia
    ];
  };

  services.xserver = {
    enable = false;
  };
}
