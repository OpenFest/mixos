{ pkgs, lib, ... }:
let
  swayCfg = (import ../configs/sway) { inherit pkgs lib; };
in {
  home.packages = with pkgs; [
    alacritty
    brightnessctl
    firefox
    grim
    playerctl
    pulseaudio # pactl comes from pulseaudio
    rofi-wayland
    swaylock
    swayidle
    slurp
    wl-clipboard
    wob
    waybar
  ];

  home.file.".zprofile".text = ''
    # Auto-start sway on first VT if not already under Wayland
    if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR: -0}" -eq 1 ]; then
      exec sway --unsupported-gpu
    fi
  '';

  wayland.windowManager.sway = {
    enable = true;

    config = swayCfg.config;
  };
}
