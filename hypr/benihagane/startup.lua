hl.on("hyprland.start", function () 

  hl.exec_cmd("swaync")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")

  hl.exec_cmd("batsignal -w 25 -W \"Charge me\" -c 15 -C \"Charge me right fucking now!\" -I ~/.config/hypr/icons/low-battery-critical.svg")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("rm -rf ~/.local/share/cliphist/*")
end)