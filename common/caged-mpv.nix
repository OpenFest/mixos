{ pkgs, videoPlayerTarget, ... }:
let
  player = pkgs.writeShellApplication {
    name = "video-player";
    runtimeInputs = [ pkgs.cage pkgs.mpv pkgs.cowsay ];
    text = ''
      function pre {
        clear
        cowsay 'entertainment will commence shortly'
      }

      pre
      while sleep 3; do
        cage -- mpv \
          --loop-file=inf \
          --osc=no \
          "${videoPlayerTarget}" \
          || continue
        pre
      done
    '';
  };
in {
  home-manager.users.human = {
    home.file.".zprofile".text = ''
      # Auto-start player on first VT if not already under Wayland
      if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR: -0}" -eq 1 ]; then
        "${player}/bin/video-player" 2>&1 | ${pkgs.moreutils}/bin/ts > /tmp/player.log
      fi
    '';
  };
}
