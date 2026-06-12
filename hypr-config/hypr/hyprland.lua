-- ============================================================
--  Hyprland 0.55.3 config — Xiaomi Pad 6 (pipa), touch tablet
--  Catppuccin Mocha · 5 workspaces · Waybar · rofi · touch-tuned
--  API matches the shipped /usr/share/hypr/hyprland.lua (0.55.3)
--
--  Modular, standalone layout (no omarchy dependency). The shipped
--  0.55 loader exposes `hl` as a global, and Lua globals are shared
--  into required files, so each module below calls `hl.*` directly.
--  package.path is extended so the submodules resolve from ~/.config.
-- ============================================================

package.path = os.getenv("HOME") .. "/.config/?.lua;" .. package.path

require("hypr.monitors")    -- displays + rotation
require("hypr.input")       -- keyboard, touch/pen devices, gestures
require("hypr.looknfeel")   -- general/decoration/animations/misc
require("hypr.bindings")    -- keybindings
require("hypr.autostart")   -- env vars + startup processes
