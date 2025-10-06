{ lib, pkgs, ... }:
let
  addExec = name: exec: { inherit name exec; };
  addMenu = name: items: { inherit name items; };
  menus = with pkgs; [
    (addExec "open terminal" "rofi-sensible-terminal")
    (addExec "run obs" "obs")
    (addExec "run x-air-edit (behringer audio mixer software)" "x-air-edit")
    (addExec "run firefox" "${firefox}/bin/firefox")
    (addExec "run audio graph manager (qpwgraph)" "${qpwgraph}/bin/qpwgraph")
    (addExec "reqet qpwgraph config (qpwgraph-config-reset)"
      "qpwgraph-config-reset")
    (addExec "reset obs config (obs-config-reset)" "obs-config-reset")
    (addExec "DANGER: run pavucontrol" "${pavucontrol}/bin/pavucontrol")
    (addExec "DANGER: reboot" "systemctl reboot")
    (addExec "DANGER: poweroff" "systemctl poweroff")
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
    "modules-center" = [ "custom/shanomenu" ];
    "custom/shanomenu" = {
      on-click = "${shanomenu}/bin/shanomenu";
      format = builtins.fromJSON ''" \uf135 " '';
    };
  };
  programs.waybar.style = ''
    #custom-shanomenu {
      color: #ebac54;
    }
    #custom-shanomenu:hover {
      color: #00ff88;
      background: rgba(255,255,255,0.4);
    }
  '';
}
