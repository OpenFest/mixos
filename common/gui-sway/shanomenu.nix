{ lib, pkgs, ... }:
let
  addExec = name: exec: { inherit name exec; };
  addMenu = name: items: { inherit name items; };
  menus = with pkgs; [
    (addExec "Firefox" "${firefox}/bin/firefox")
    (addExec "obs" "obs")
    (addExec "pavucontrol" "${pavucontrol}/bin/pavucontrol")
    (addExec "qpwgraph" "${qpwgraph}/bin/qpwgraph")
    (addExec "terminal" "rofi-sensible-terminal")
    (addExec "qpwgraph-config-reset" "qpwgraph-config-reset")
    (addExec "obs-config-reset" "obs-config-reset")
    (addExec "reboot" "systemctl reboot")
    (addExec "poweroff" "systemctl poweroff")
  ];
  binding = "Mod4+Shift+d";
  shanomenu = with pkgs;
  # TODO: make nested menus work
    writeScriptBin "shanomenu" ''
      #!${rofi-menugen}/bin/rofi-menugen

          #begin main
          name="ShanoMenu"
          ${
            lib.concatStrings (lib.map (x: ''
              add_exec '${x.name}' '${x.exec}'
            '') menus)
          }
          #end main'';
in {
  home.packages = [ shanomenu ];

  wayland.windowManager.sway.config.keybindings."${binding}" =
    "exec ${shanomenu}/bin/shanomenu";

  programs.waybar.settings.main = {
    "modules-left" = [ "custom/shanomenu" ];
    "custom/shanomenu" = {
      on-click = "${shanomenu}/bin/shanomenu";
      format = "RUN";
    };
  };
}
