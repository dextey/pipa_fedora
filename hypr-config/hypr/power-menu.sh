#!/usr/bin/env bash
# Compact power menu via rofi (replaces the oversized wlogout buttons).
# Save as ~/.config/hypr/power-menu.sh and chmod +x it.

# Log out regardless of how the Hyprland session was launched.
# `hyprctl dispatch exit` only quits the compositor, which ends the session ONLY
# when GDM launched Hyprland directly. Under UWSM (or any wrapper) that leaves the
# session running, so we fall back to logind, which always returns you to GDM.
logout_session() {
  if command -v uwsm >/dev/null 2>&1 && uwsm check is-active >/dev/null 2>&1; then
    uwsm stop && return            # clean path for UWSM-managed sessions
  fi
  hyprctl dispatch exit 2>/dev/null # plain-Hyprland path
  sleep 1                           # if we're still alive, the exit didn't log us out:
  loginctl terminate-user "$USER"   # logind tears the whole session down -> back to GDM
}

# Anchor the menu to the top-right, just under the Waybar power button
# (location/anchor = north east), instead of the rofi default (screen center).
# Offsets: inset ~10px from the right edge, drop ~50px to clear the 38px bar.
menu_pos='window {
  width: 300px;
  location: north east;
  anchor:   north east;
  x-offset: -10px;
  y-offset: 50px;
}
listview { lines: 4; }'

chosen=$(printf " Screen off\n Logout\n Reboot\n Shutdown" \
  | rofi -dmenu -i -p "Power" -theme-str "$menu_pos")

# NOTE: no "Lock" / hyprlock entry — the Wayland session-lock protocol blocks the
# on-screen keyboard, which would trap this keyboard-less tablet. "Screen off"
# uses DPMS instead (wakes on touch).
case "$chosen" in
  *"Screen off") hyprctl dispatch dpms off ;;
  *Logout)       logout_session ;;
  *Reboot)       systemctl reboot ;;
  *Shutdown)     systemctl poweroff ;;
esac
