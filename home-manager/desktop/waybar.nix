{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      position = "top";
      layer = "top";
      height = 34;
      margin-top = 0;
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;
      modules-left = [
        "custom/launcher"
        "cpu"
        "memory"
        "network#usage"
      ];
      modules-center = [
        "hyprland/workspaces"
      ];
      modules-right = [
        "tray"
        "pulseaudio"
        "network#status"
        "battery"
        "clock"
      ];
      clock = {
        format = "  {:%a, %b %d, %H:%M}";
        tooltip = "true";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        format-alt = "  {:%m/%d}";
      };
      "wlr/workspaces" = {
        active-only = false;
        all-outputs = false;
        on-click = "activate";
        disable-scroll = false;
        on-scroll-up = "hyprctl dispatch workspace e-1";
        on-scroll-down = "hyprctl dispatch workspace e+1";
        format = "{name}";
        format-icons = {
          urgent = "";
          active = "";
          default = "";
          sort-by-number = true;
        };
      };
      battery = {
        states = {
          good = 95;
          warning = 35;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
        format-charging = "  {capacity}%";
        format-plugged = "  {capacity}%";
        tooltip-format = "{time}";
        format-icons = ["" "" "" "" ""];
      };
      cpu = {
        format = "󰻠 {usage}%";
        format-alt = "󰻠 {avg_frequency} GHz";
        interval = 3;
      };
      memory = {
        format = "󰍛 {}%";
        format-alt = "󰍛 {used}/{total} GiB";
        tooltip-format = "swap: {swapUsed}/{swapTotal} GiB";
        interval = 3;
      };
      "network#usage" = {
        format = "󱚻  {bandwidthTotalBytes}";
        format-alt = "󱚻  {bandwidthUpBytes}  {bandwidthDownBytes} ";
        tooltip-format = "{bandwidthUpBits}  {bandwidthDownBits} ";
        format-disconnected = "󱚻  ?";
        interval = 3;
      };
      "network#status" = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "󰈀  {ifname} (eth)";
        tooltip-format-wifi = "({frequency} GHz) Connected to {essid} ({gwaddr}) via {ifname} ({ipaddr})";
        tooltip-format-ethernet = "Connected via {ifname} ({gwaddr} -> {ipaddr})";
        format-linked = "󰈀  {ifname} (eth) (No IP)";
        format-disconnected = "󰖪  ?";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-icons = {
          default = ["󰕿" "󰖀" "󰕾"];
        };
        format-muted = "󰝟";
        scroll-step = 5;
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      "custom/launcher" = {
        format = "";
        on-click = "${pkgs.rofi}/bin/rofi -show drun";
        tooltip = false;
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0px;
        font-family: serif;
        font-size: 12px;
        min-height: 0;
      }
    '';
  };
}