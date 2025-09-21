{ config, pkgs, lib, ... }:
let
  mod = "Mod4";
  term = "alacritty";
  menu = "rofi -show combi -show-icons";

  swayCfg = {
    modifier = "${mod}";

    terminal = "alacritty";
    bars = [
      # {
      #   command = "swaybar";
      # }
      {
        statusCommand = "${pkgs.i3status}/bin/i3status";
      }
    ];

    startup = [
      { command = "${pkgs.wayvnc}/bin/wayvnc '::' &> /tmp/wayvnc.log"; }
    ];

    assigns = {
      "projector" = [{ title = ".*Projector - Scene:.*"; app_id = "com.obsproject.Studio"; }];
      "multiview" = [{ title = ".*Projector - Multiview"; app_id = "com.obsproject.Studio"; }];
    };

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

      # Scratchpad
      "${mod}+Shift+minus" = "move scratchpad";
      "${mod}+minus" = "scratchpad show";
      # Resize mode

      "${mod}+r" = "mode resize";
      # Workspaces 1–10 (switch)
      "${mod}+1" = "workspace number 1";
      "${mod}+2" = "workspace number 2";
      "${mod}+3" = "workspace number 3";
      "${mod}+4" = "workspace number 4";
      "${mod}+5" = "workspace number 5";
      "${mod}+6" = "workspace number 6";
      "${mod}+7" = "workspace number 7";
      "${mod}+8" = "workspace number 8";
      "${mod}+9" = "workspace number 9";
      "${mod}+0" = "workspace number 10";

      # Move focused container to workspace 1–10
      "${mod}+Shift+1" = "move container to workspace number 1";
      "${mod}+Shift+2" = "move container to workspace number 2";
      "${mod}+Shift+3" = "move container to workspace number 3";
      "${mod}+Shift+4" = "move container to workspace number 4";
      "${mod}+Shift+5" = "move container to workspace number 5";
      "${mod}+Shift+6" = "move container to workspace number 6";
      "${mod}+Shift+7" = "move container to workspace number 7";
      "${mod}+Shift+8" = "move container to workspace number 8";
      "${mod}+Shift+9" = "move container to workspace number 9";
      "${mod}+Shift+0" = "move container to workspace number 10";
    };

    output."*" = { background = "${sway-user-data}/wallpaper.jpg fill"; };
    output."${config.mixos.videoOutputs.projector}" = {
      pos = "5000 0";
      bg = "#ebac54 solid_color";
    };
    output."${config.mixos.videoOutputs.multiview}" = {
      pos = "10000 0";
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
      {
        workspace = "1";
        output = config.mixos.videoOutputs.main;
      }
    ];
  };

  sway-user-data = pkgs.stdenvNoCC.mkDerivation rec {
    name = "sway-user-data";
    meta.description = "Extra user files for sway";
    src = ./data;
    buildInputs = [ pkgs.coreutils ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -vfT wallpaper.jpg $out/wallpaper.jpg
    '';
  };
in {
  options.mixos.videoOutputs = lib.mkOption {
    type = lib.types.attrsOf (lib.types.str);
    default = {};
    description = ''
      Mapping of video friendly video output names to their
      respective hardware names
    '';
  };

  config = {
    home-manager.users.human = {
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
      };

      # programs.waybar = {
      #   enable = false;

      #   settings = {
      #     mainBar = {
      #       layer = "top";
      #       position = "top";
      #       height = 28;

      #       modules-left = [ "sway/workspaces" "sway/mode" ];
      #       modules-center = [ "clock" ];
      #       modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

      #       clock = {
      #         format = "{:%Y-%m-%d %H:%M}";
      #       };
      #     };
      #   };

      #   # This sets the CSS styling (usually ~/.config/waybar/style.css)
      #   style = ''
      #     * {
      #       font-family: "Noto Sans", "Font Awesome 6 Free", "Noto Color Emoji";
      #       font-size: 12px;
      #     }

      #     window#waybar {
      #       background: #1e1e2e;
      #       color: #cdd6f4;
      #     }

      #     #clock {
      #       padding: 0 10px;
      #     }
      #   '';
      # };
    };
  };
}
