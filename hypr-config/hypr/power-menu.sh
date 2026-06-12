#!/usr/bin/env bash
# Compact power menu via rofi (replaces the oversized wlogout buttons).
# Save as ~/.config/hypr/power-menu.sh and chmod +x it.

chosen=$(printf " Screen off\n Logout\n Reboot\n Shutdown" \
  | rofi -dmenu -i -p "Power" -theme-str 'window {width: 300px;} listview {lines: 4;}')

# NOTE: no "Lock" / hyprlock entry — the Wayland session-lock protocol blocks the
# on-screen keyboard, which would trap this keyboard-less tablet. "Screen off"
# uses DPMS instead (wakes on touch).
case "$chosen" in
  *"Screen off") hyprctl dispatch dpms off ;;
  *Logout)       hyprctl dispatch exit ;;
  *Reboot)       systemctl reboot ;;
  *Shutdown)     systemctl poweroff ;;
esac
