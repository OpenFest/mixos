{ pkgs, ... }: {
  home.username = "human";
  home.homeDirectory = "/home/human";

  home.packages = [ pkgs.htop pkgs.cowsay ];

  home.file.".zprofile".text = ''
    # Auto-start sway on first VT if not already under Wayland
    if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR: -0}" -eq 1 ]; then
      exec sway --unsupported-gpu
    fi
  '';
}
