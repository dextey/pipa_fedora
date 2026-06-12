-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Make apps pick Wayland backends where possible
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_BACKEND", "wayland,x11")

-------------------
---- AUTOSTART ----
-------------------
-- 0.55 uses hl.on("hyprland.start", ...) + hl.exec_cmd(), NOT exec-once.
hl.on("hyprland.start", function()
    -- status bar
    hl.exec_cmd("waybar")
    -- notifications (mako; config sets a 5s timeout so popups auto-dismiss)
    hl.exec_cmd("mako")
    -- wallpaper
    hl.exec_cmd("hyprpaper")
    -- night light (warm tint in the evening; profiles in hyprsunset.conf)
    hl.exec_cmd("hyprsunset")
    -- polkit agent (GUI password prompts under Hyprland)
    hl.exec_cmd("/usr/libexec/polkit-gnome-authentication-agent-1")
    -- clipboard history
    hl.exec_cmd("wl-paste --watch cliphist store")
    -- network/bluetooth tray applets (so Waybar tray shows them)
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    -- on-screen keyboard: try squeekboard, fall back to wvkbd
    hl.exec_cmd("sh -c 'command -v squeekboard >/dev/null && squeekboard || (command -v wvkbd-mobintl >/dev/null && wvkbd-mobintl -L 280)'")
    -- idle -> lock (screen-off only, NO suspend; pipa resume is slow)
    hl.exec_cmd("hypridle")
end)
