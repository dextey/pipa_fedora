#!/usr/bin/env bash
#
# install-hypr-config.sh
# Places the Catppuccin/touch Hyprland config set for the Xiaomi Pad 6 (pipa).
# Run from the extracted hypr-config/ folder, as your normal user:
#   chmod +x install-hypr-config.sh && ./install-hypr-config.sh
#
set -uo pipefail
src="$(cd "$(dirname "$0")" && pwd)"
cfg="$HOME/.config"
ts="$(date +%Y%m%d-%H%M%S)"

say()  { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
ok()   { printf '\e[1;32m  ok\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m  !!\e[0m %s\n' "$*"; }

# back up an existing file/dir before overwriting
place() {  # place <src-rel> <dest-abs>
  local s="$src/$1" d="$2"
  mkdir -p "$(dirname "$d")"
  if [[ -e "$d" ]]; then
    cp -a "$d" "$d.bak-$ts" && warn "backed up $d -> $d.bak-$ts"
  fi
  cp -a "$s" "$d" && ok "installed $d"
}

# ---------- 1. missing packages ----------
say "Installing packages still needed (hyprpaper, hypridle, rofi, etc.)"
for p in hyprpaper hypridle hyprlock rofi-wayland alacritty mako \
         waybar nautilus brightnessctl playerctl pavucontrol \
         network-manager-applet blueman cliphist polkit-gnome \
         grim slurp jetbrains-mono-fonts-all fontawesome6-fonts; do
  rpm -q "$p" &>/dev/null && { ok "$p present"; continue; }
  sudo dnf install -y "$p" &>/dev/null && ok "installed $p" || warn "could not install $p (check name/repo)"
done

# on-screen keyboard: whichever exists
if ! command -v squeekboard &>/dev/null && ! command -v wvkbd-mobintl &>/dev/null; then
  sudo dnf install -y squeekboard &>/dev/null && ok "installed squeekboard" \
    || warn "no OSK installed — build wvkbd from source (github.com/jjsullivan5196/wvkbd)"
fi

# ---------- 1b. JetBrainsMono Nerd Font (fixes 'boxes' in waybar/rofi) ----------
say "Installing JetBrainsMono Nerd Font"
if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  ok "Nerd Font already present"
else
  fdir="$HOME/.local/share/fonts"; mkdir -p "$fdir"
  if command -v curl &>/dev/null && command -v unzip &>/dev/null && \
     curl -fsL -o "$fdir/JetBrainsMono.zip" \
       "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" 2>/dev/null; then
    ( cd "$fdir" && unzip -oq JetBrainsMono.zip && rm -f JetBrainsMono.zip )
    fc-cache -f >/dev/null 2>&1 && ok "installed JetBrainsMono Nerd Font"
  else
    warn "could not download the Nerd Font — install curl+unzip and re-run, or fetch it manually"
  fi
fi

# ---------- 1c. power-key behaviour (stop the tablet shutting down) ----------
say "Setting physical power button to NOT shut down (short press) "
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/10-power.conf >/dev/null <<'EOF'
[Login]
HandlePowerKey=ignore
HandlePowerKeyLongPress=poweroff
EOF
ok "logind power-key rule written (reboot to apply)"

# ---------- 2. place config files ----------
say "Placing config files (existing ones are backed up)"
place "hypr/hyprland.lua"        "$cfg/hypr/hyprland.lua"
# modular hyprland config (required by hyprland.lua's require() calls)
place "hypr/monitors.lua"        "$cfg/hypr/monitors.lua"
place "hypr/input.lua"           "$cfg/hypr/input.lua"
place "hypr/looknfeel.lua"       "$cfg/hypr/looknfeel.lua"
place "hypr/bindings.lua"        "$cfg/hypr/bindings.lua"
place "hypr/autostart.lua"       "$cfg/hypr/autostart.lua"
place "hypr/hyprlock.conf"       "$cfg/hypr/hyprlock.conf"
place "hypr/hypridle.conf"       "$cfg/hypr/hypridle.conf"
place "hyprpaper/hyprpaper.conf" "$cfg/hypr/hyprpaper.conf"
place "waybar/config.jsonc"      "$cfg/waybar/config.jsonc"
place "waybar/style.css"         "$cfg/waybar/style.css"
place "rofi/config.rasi"         "$cfg/rofi/config.rasi"
place "mako/config"              "$cfg/mako/config"
place "alacritty/alacritty.toml" "$cfg/alacritty/alacritty.toml"
place "hypr/power-menu.sh"        "$cfg/hypr/power-menu.sh"
chmod +x "$cfg/hypr/power-menu.sh" 2>/dev/null && ok "power-menu.sh executable"

# ---------- 3. wallpaper ----------
say "Setting a wallpaper"
wp="$cfg/hypr/wallpaper.png"
if [[ ! -f "$wp" ]]; then
  # try to fetch a Catppuccin wallpaper; fall back to a shipped one
  if command -v curl &>/dev/null && \
     curl -fsL -o "$wp" "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/evening-sky.png" 2>/dev/null; then
    ok "downloaded a Catppuccin wallpaper"
  elif [[ -f /usr/share/hypr/wall0.png ]]; then
    cp /usr/share/hypr/wall0.png "$wp" && warn "download failed — used shipped /usr/share/hypr/wall0.png"
  else
    warn "no wallpaper set — drop any image at $wp"
  fi
else
  ok "wallpaper already present at $wp"
fi

# ---------- 4. mako: apply now if running ----------
if pgrep -x mako &>/dev/null; then
  makoctl reload &>/dev/null && ok "reloaded mako (notifications now time out after 5s)"
fi

say "Done."
cat <<'EOF'
------------------------------------------------------------------------
NEXT:
  1. Confirm which OSK you have:   which squeekboard wvkbd-mobintl
     - if neither, build wvkbd (notes in chat) and the autostart will pick it up.
  2. Reload Hyprland config:       hyprctl reload
     (or log out and back into the Hyprland session)
  3. The stuck notification is fixed by the new ~/.config/mako/config
     (default-timeout=5000). If one is still on screen: makoctl dismiss --all
  4. Check Waybar came up; if not, run `waybar` in a terminal to see errors.

KEYBINDS (Super = Windows key):
  Super+Return / Super+Q ... terminal (alacritty)
  Super+R / Super+Space ..... app launcher (rofi)
  Super+E ................... files (nautilus)
  Super+C ................... close window
  Super+1..5 ............... switch workspace   (3-finger swipe also works)
  Super+Shift+1..5 ......... move window to workspace
  Super+F .................. fullscreen   Super+V floating
  Super+L .................. lock         Super+M power menu (rofi)
  Print .................... region screenshot to clipboard

Backups of any replaced files are saved as <file>.bak-TIMESTAMP next to them.
------------------------------------------------------------------------
EOF
