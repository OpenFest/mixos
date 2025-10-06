{ pkgs, ... }: {
  home-manager.users.human.home.packages = with pkgs; [
    pwvucontrol
    pavucontrol
    lsp-plugins
    guitarix # absolutely essential lol
    pulseaudio # for pactl, fixme
    audacity

    jack_mixer
    x-air-edit
  ];
}
