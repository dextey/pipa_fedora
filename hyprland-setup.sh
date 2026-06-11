#!/usr/bin/env bash
#
# hyprland-pipa-setup.sh
# Clean Hyprland setup for Fedora (aarch64) on the Xiaomi Pad 6 (pipa).
#
# What it does:
#   1. Enables the lionheartp/Hyprland COPR (has aarch64 builds for F43/44/rawhide)
#   2. Installs everything available in resilient passes (missing pkgs are
#      skipped, not fatal) and reports exactly what wasn't found
#   3. Enables the couple of system services that need it
#   4. Prints the build-from-source leftovers and next steps
#
# Assumes you're installing ALONGSIDE GNOME, so packages GNOME already provides
# (NetworkManager, bluez, xdg-desktop-portal-gtk, base fonts, PipeWire) are NOT
# reinstalled here. Only Hyprland-session components GNOME can't share are added.
#
# Safe to re-run. Does NOT remove GNOME — Hyprland is added alongside it,
# and you pick the session at the GDM login screen.
#
# Run as your normal user (it uses sudo where needed), NOT as root:
#   chmod +x hyprland-pipa-setup.sh && ./hyprland-pipa-setup.sh
#
set -uo pipefail   # intentionally NOT -e: we want to continue past missing pkgs

# ---------- logging ----------
c_blue=$'\e[1;34m'; c_grn=$'\e[1;32m'; c_yel=$'\e[1;33m'; c_red=$'\e[1;31m'; c_rst=$'\e[0m'
say()  { printf '%s==>%s %s\n' "$c_blue" "$c_rst" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$c_grn" "$c_rst" "$*"; }
warn() { printf '%s  !!%s %s\n' "$c_yel" "$c_rst" "$*"; }
err()  { printf '%s  XX%s %s\n' "$c_red" "$c_rst" "$*"; }

MISSING_ALL=()

# ---------- sanity checks ----------
if [[ $EUID -eq 0 ]]; then
  err "Run this as your normal user, not root. It calls sudo itself."
  exit 1
fi
command -v dnf >/dev/null || { err "dnf not found — is this Fedora?"; exit 1; }
arch="$(uname -m)"
[[ "$arch" == "aarch64" ]] || warn "Arch is '$arch', not aarch64 — the COPR is aarch64-only; continuing anyway."

# Install a group; skip unavailable packages instead of failing the whole run,
# then report which ones didn't end up installed.
install_group() {
  local name="$1"; shift
  local pkgs=("$@")
  say "Installing group: $name"
  sudo dnf install -y --skip-unavailable "${pkgs[@]}" || warn "dnf returned non-zero for '$name' (continuing)"
  local missing=()
  local p
  for p in "${pkgs[@]}"; do
    rpm -q "$p" &>/dev/null || missing+=("$p")
  done
  if ((${#missing[@]})); then
    warn "Not installed (unavailable on this repo/arch, or named differently): ${missing[*]}"
    MISSING_ALL+=("${missing[@]}")
  else
    ok "All of '$name' installed."
  fi
}

# =========================================================================
say "Step 1/5 — enable the Hyprland COPR (lionheartp — builds aarch64)"
# Remove the wrong aarch64-fork COPR if a previous run enabled it (it had no
# usable builds, which made the whole hypr group come up empty).
sudo dnf copr remove technochip/Hyprland-aarch64 2>/dev/null || true
# lionheartp/Hyprland publishes aarch64 packages for F43/F44/rawhide.
sudo dnf copr enable -y lionheartp/Hyprland || warn "COPR enable failed — check the name at copr.fedorainfracloud.org"
sudo dnf -y makecache || true

# =========================================================================
say "Step 2/5 — install packages"

# --- Core Hyprland ecosystem (from the lionheartp COPR) ---
# If any of THESE show as missing, stop and check the COPR — they're essential.
install_group "hypr-core" \
  hyprland hyprlock hypridle hyprpaper hyprpicker hyprcursor \
  xdg-desktop-portal-hyprland

# --- Bar / launcher / terminal / notifications (all from Fedora main repos) ---
# rofi-wayland is in Fedora's repos, NOT the COPR — it shouldn't depend on it.
install_group "desktop-shell" \
  waybar rofi-wayland kitty mako \
  wl-clipboard cliphist grim slurp

# --- System glue: polkit agent (GUI password prompts) ---
# GNOME's own polkit agent only runs in a GNOME session, so Hyprland still
# needs a standalone one. xdg-desktop-portal-gtk is already present from GNOME.
install_group "polkit" \
  polkit-gnome

# --- Hardware controls your keybinds / Waybar modules will call ---
# NetworkManager + bluez are already installed by GNOME — not repeated here.
# nm-applet/blueman are optional tray togglers for the Hyprland session.
install_group "controls" \
  brightnessctl playerctl pavucontrol \
  network-manager-applet blueman

# --- Theming so GTK + Qt apps look consistent UNDER Hyprland (optional) ---
# GNOME's own theming doesn't apply in a Hyprland session.
install_group "theming" \
  nwg-look qt5ct qt6ct

# --- Fonts: only the icon font Waybar/rofi need; GNOME already ships the rest ---
# Correct package name is fontawesome6-fonts (NOT "fontawesome").
install_group "fonts" \
  fontawesome6-fonts fontawesome-fonts jetbrains-mono-fonts-all

# --- Tablet essentials: on-screen keyboard + sensor proxy ---
# Tries both common OSKs; whichever exists in your repos gets installed.
# wvkbd often isn't packaged for aarch64 — if both are missing, build wvkbd.
install_group "tablet" \
  squeekboard wvkbd iio-sensor-proxy

# =========================================================================
say "Step 3/5 — enable services"
# bluez/NetworkManager are already enabled by GNOME; this is just a safety net.
sudo systemctl enable --now bluetooth.service 2>/dev/null && ok "bluetooth enabled" || warn "bluetooth.service unchanged (likely already on)"
# NOTE: iio-sensor-proxy is intentionally NOT auto-enabled — pipa sensors are
# disabled by default and flaky after suspend. Enable manually if you want
# auto-rotation/brightness:  sudo systemctl enable --now iio-sensor-proxy

# =========================================================================
say "Step 4/5 — seed a minimal config (only if you don't have one yet)"
cfg="$HOME/.config/hypr"
if [[ ! -f "$cfg/hyprland.conf" ]]; then
  mkdir -p "$cfg"
  if [[ -f /usr/share/hypr/hyprland.conf ]]; then
    cp /usr/share/hypr/hyprland.conf "$cfg/hyprland.conf"
    ok "Copied default hyprland.conf to $cfg/ — edit it to taste."
  else
    warn "No default hyprland.conf found to copy; you'll write one (see Hyprland wiki)."
  fi
else
  ok "Existing $cfg/hyprland.conf left untouched."
fi

# =========================================================================
say "Step 5/5 — summary"
echo
if ((${#MISSING_ALL[@]})); then
  warn "These were NOT installed (unavailable on aarch64/this repo, or different name):"
  printf '       - %s\n' "${MISSING_ALL[@]}" | sort -u
  echo
fi

cat <<'EOF'
------------------------------------------------------------------------
BUILD-FROM-SOURCE / NOT IN REPOS (handle separately if you want them):
  - swww          animated wallpaper daemon (alt to hyprpaper) — Rust build
  - hyprgrass     Hyprland TOUCH GESTURES plugin — highly worth it on a
                  tablet; build via `hyprpm add https://github.com/horriblename/hyprgrass`
  - hyprshot      nicer screenshot wrapper (grim+slurp already cover basics)
  - hyprpolkitagent  newer polkit agent (polkit-gnome already installed as fallback)
  - wvkbd         if it wasn't found above, build from github.com/jjsullivan5196/wvkbd

NERD FONT ICONS (for full Waybar/rofi glyph coverage):
  fontawesome covers most default Waybar glyphs, but for a themed setup grab a
  Nerd Font manually:
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip && fc-cache -f

NEXT STEPS:
  1. Log out of GNOME.
  2. At the GDM login screen, click the gear/session icon and pick "Hyprland".
  3. If Hyprland won't start or looks broken, just log out and pick GNOME again
     — your working desktop is untouched. That's your safety net.
  4. Autostart your bits by adding exec-once lines to ~/.config/hypr/hyprland.conf:
        exec-once = waybar
        exec-once = mako
        exec-once = hyprpaper
        exec-once = nm-applet --indicator
        exec-once = wl-paste --watch cliphist store
        exec-once = /usr/libexec/polkit-gnome-authentication-agent-1
     (On a tablet, also launch your OSK, e.g.  exec-once = squeekboard )

CAUTION (pipa-specific):
  - Don't wire hypridle to SUSPEND — resume is slow on this kernel. Prefer
    screen-off + hyprlock on idle, and keep the device awake.
  - Auto-rotation needs iio-sensor-proxy enabled + a hyprctl transform script,
    and sensors can break after suspend.
------------------------------------------------------------------------
EOF

ok "Done. Review any 'not installed' items above before logging into Hyprland."