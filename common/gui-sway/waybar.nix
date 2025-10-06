{ pkgs, ... }: {

  home.packages = with pkgs; [ pavucontrol ];

  programs.waybar = {
    enable = true;

    #systemd.enable = true;

    settings.main = {
      height = 25;
      spacing = 4;

      "modules-left" =
        [ "sway/workspaces" "sway/mode" "sway/scratchpad" "sway/window" ];
      "modules-center" = [ ];
      "modules-right" = [
        "network"
        "pulseaudio"
        "cpu"
        "memory"
        "temperature"
        "battery"
        "sway/language"
        "clock"
        "tray"
      ];

      "sway/workspaces" = {
        "disable-scroll" = false;
        "all-outputs" = true;
        "warp-on-scroll" = false;
        "format" = "{name}";
      };

      "keyboard-state" = {
        numlock = true;
        capslock = true;
        format = "{name} {icon}";
        "format-icons" = {
          locked = "";
          unlocked = "";
        };
      };

      "sway/mode" = { format = ''<span style="italic">{}</span>''; };

      "sway/scratchpad" = {
        format = "{icon} {count}";
        "show-empty" = false;
        "format-icons" = [ "" "" ];
        tooltip = true;
        "tooltip-format" = "{app}: {title}";
      };

      tray = {
        # "icon-size" = 21;
        spacing = 10;
      };

      clock = {
        "tooltip-format" = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
        "format-alt" = "{:%Y-%m-%d}";
      };

      cpu = {
        format = "{usage}% ";
        tooltip = true;
      };

      memory = { format = "{}% "; };

      temperature = {
        "critical-threshold" = 80;
        format = "{temperatureC}°C {icon}";
        "format-icons" = [ "" "" "" ];
      };

      backlight = {
        # "device" = "acpi_video1";
        format = "{percent}% {icon}";
        "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        "format-charging" = "{capacity}% ";
        "format-plugged" = "{capacity}% ";
        "format-alt" = "{time} {icon}";
        "format-icons" = [ "" "" "" "" "" ];
      };

      "battery#bat2" = { bat = "BAT2"; };

      network = {
        #interface = "enp6s0"; # adjust to your interface
        "format-wifi" = "({signalStrength}%) ";
        "format-ethernet" = "{ipaddr}/{cidr} 󰈀";
        "tooltip-format" = "{ifname} via {gwaddr} ";
        "format-linked" = "{ifname} (No IP) ";
        "format-disconnected" = "Disconnected 󰌙";
        "format-alt" = "{ifname}: {ipaddr}/{cidr}";
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        "format-muted" = " {format_source}";
        "format-source" = "{volume}% ";
        "format-source-muted" = "";
        "format-icons".default = [ "" "" "" ];
        "on-click" = "pavucontrol";
      };
    };

    style = (builtins.readFile ./waybar-style.css);
  };

}
