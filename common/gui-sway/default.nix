{
  config,
  pkgs,
  lib,
  ...
}:
let
  mod = "Mod4";
  term = "alacritty";
  menu = "rofi -show combi -show-icons";

  windowMatchers = ''
    for_window [app_id="^com\.obsproject\.Studio$" title=".*Projector - Scene:.*"] \
      move container to workspace projector, fullscreen enable;

    for_window [app_id="^com\.obsproject\.Studio$" title=".*Projector - Multiview"] \
      move container to workspace multiview, fullscreen enable;

    for_window [app_id="^((?!com\.obsproject\.Studio).)*$"] \
      move container to output ${config.mixos.videoOutputs.main}, focus;

    for_window [app_id="^com\.obsproject\.Studio$" title="^((?!.*Projector -.*).)*$"] \
      move container to output ${config.mixos.videoOutputs.main}, focus;
  '';

  swayCfg = {
    modifier = "${mod}";

    terminal = "alacritty";
    bars = [ { command = "waybar"; } ];

    startup = [ { command = "${pkgs.wayvnc}/bin/wayvnc '::' &> /tmp/wayvnc.log"; } ];

    workspaceLayout = "tabbed";
    defaultWorkspace = "workspace number 1";

    keybindings = {
      # Basics
      "${mod}+Return" = "exec ${term}";
      "${mod}+Shift+q" = "kill";
      "${mod}+d" = "exec ${menu}";
      "${mod}+Shift+c" = "reload";
      "${mod}+Shift+e" =
        "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit' ";

      # Move focus
      "${mod}+h" = "focus left";
      "${mod}+j" = "focus down";
      "${mod}+k" = "focus up";
      "${mod}+l" = "focus right";
      "${mod}+Left" = "focus left";
      "${mod}+Down" = "focus down";
      "${mod}+Up" = "focus up";
      "${mod}+Right" = "focus right";

      # Move windows
      "${mod}+Shift+h" = "move left";
      "${mod}+Shift+j" = "move down";
      "${mod}+Shift+k" = "move up";
      "${mod}+Shift+l" = "move right";
      "${mod}+Shift+Left" = "move left";
      "${mod}+Shift+Down" = "move down";
      "${mod}+Shift+Up" = "move up";
      "${mod}+Shift+Right" = "move right";

      # Layout
      "${mod}+b" = "splith";
      "${mod}+v" = "splitv";
      "${mod}+s" = "layout stacking";
      "${mod}+w" = "layout tabbed";
      "${mod}+e" = "layout toggle split";
      "${mod}+f" = "fullscreen";
      "${mod}+Shift+space" = "floating toggle";
      "${mod}+space" = "focus mode_toggle";
      "${mod}+a" = "focus parent";

      # Resize mode
      "${mod}+r" = "mode resize";
    }
    // (forEveryMainWorkspaceKV (n: {
      "${mod}+${n}" = "workspace number ${n}";
      "${mod}+Shift+${n}" = "move container to workspace number ${n}";
    }));

    output."*" = {
      background = "${sway-user-data}/wallpaper.jpg fill";
    };
    output."${config.mixos.videoOutputs.main}" = {
      pos = "0 0";
    };
    output."${config.mixos.videoOutputs.projector}" = {
      pos = "-5000 0";
      bg = "#ebac54 solid_color";
    };
    output."${config.mixos.videoOutputs.multiview}" = {
      pos = "5000 0";
    };

    workspaceOutputAssign = [
      {
        workspace = "projector";
        output = config.mixos.videoOutputs.projector;
      }
      {
        workspace = "multiview";
        output = config.mixos.videoOutputs.multiview;
      }
    ]
    ++ (forEveryMainWorkspace (n: {
      workspace = "${n}";
      output = config.mixos.videoOutputs.main;
    }));
  };

  sway-user-data = pkgs.stdenvNoCC.mkDerivation rec {
    name = "sway-user-data";
    meta.description = "Extra user files for sway";
    src = ./data;
    buildInputs = [ pkgs.coreutils ];
    phases = [
      "unpackPhase"
      "installPhase"
    ];
    installPhase = ''
      mkdir -p $out
      cp -vfT wallpaper.jpg $out/wallpaper.jpg
    '';
  };

  forEveryMainWorkspace = f: builtins.map f (builtins.map toString (lib.lists.range 1 9));
  forEveryMainWorkspaceKV = f: lib.attrsets.mergeAttrsList (forEveryMainWorkspace f);
in
{
  options.mixos.videoOutputs = lib.mkOption {
    type = lib.types.attrsOf (lib.types.str);
    default = { };
    description = ''
      Mapping of video friendly video output names to their
      respective hardware names
    '';
  };

  config = {
    home-manager.users.human = {
      imports = [
        ./waybar.nix
        ./shanomenu.nix
      ];

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
        xwayland

        nerd-fonts.noto
        nerd-fonts.droid-sans-mono
        font-awesome
      ];

      home.file.".zprofile".text = ''
        # Auto-start sway on first VT if not already under Wayland
        if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR: -0}" -eq 1 ]; then
          exec sway --unsupported-gpu
        fi
      '';

      wayland.windowManager.sway = {
        enable = true;

        config = swayCfg;
        extraConfig = ''
          ${windowMatchers}
        '';
      };
    };
  };
}
