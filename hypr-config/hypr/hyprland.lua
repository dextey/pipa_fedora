-- ============================================================
--  Hyprland 0.55.3 config — Xiaomi Pad 6 (pipa), touch tablet
--  Catppuccin Mocha · 5 workspaces · Waybar · rofi · touch-tuned
--  API matches the shipped /usr/share/hypr/hyprland.lua (0.55.3)
-- ============================================================

------------------
---- MONITORS ----
------------------
-- DSI-1, 1800x2880@120, scale 2, transform 3 = landscape (your working value)
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = "auto",
    transform = 3,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "alacritty"
local fileManager = "nautilus"
local menu        = "rofi -show drun"
local browser     = "firefox"

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

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Catppuccin Mocha accent (mauve) borders.
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,           -- tighter than default; more screen for a tablet
        border_size = 2,
        col = {
            -- mauve -> blue gradient active border
            active_border   = { colors = { "rgba(cba6f7ee)", "rgba(89b4faee)" }, angle = 45 },
            inactive_border = "rgba(45475aaa)", -- surface1
        },
        resize_on_border = true, -- easier to grab on touch
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee11111b,   -- crust
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },
})

-- Default curves/animations (kept from shipped config)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

hl.config({ dwindle = { preserve_split = true } })
hl.config({ master  = { new_status = "master" } })

----------------
----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper = 0,     -- no anime mascot; we use hyprpaper
        disable_hyprland_logo   = true,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = { natural_scroll = true },
    },
})

-- TOUCHSCREEN: must match the monitor transform or taps land in the wrong spot.
-- Device name from `hyprctl devices` on this tablet.
hl.device({
    name      = "nvtcapacitivetouchscreen",
    transform = 3,
})

-- Stylus, same rotation so the pen tracks correctly.
hl.device({
    name      = "nvtcapacitivepen",
    transform = 3,
})

-- 3-finger horizontal swipe = switch workspace (touch-friendly, no plugin needed)
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",             hl.dsp.exec_cmd(terminal))   -- alias
hl.bind(mainMod .. " + C",             hl.dsp.window.close())
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + R",             hl.dsp.exec_cmd(menu))       -- rofi app list
hl.bind(mainMod .. " + Space",         hl.dsp.exec_cmd(menu))       -- alias for muscle memory
hl.bind(mainMod .. " + V",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J",             hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + L",             hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + M",             hl.dsp.exec_cmd("~/.config/hypr/power-menu.sh"))  -- compact rofi power menu
-- Physical power button: lock instead of shutdown (logind set to ignore it)
hl.bind("XF86PowerOff",                hl.dsp.exec_cmd("hyprlock"))
hl.bind("Print",                       hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy")) -- region screenshot -> clipboard

-- Focus move (arrows)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- 5 workspaces (Super+1..5 switch, Super+Shift+1..5 move window)
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Drag/resize with mouse (and touch long-press-drag)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness / media (work via the hardware keys + Waybar)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- WINDOW RULES ----
--------------------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Float common dialogs/tools so they don't tile awkwardly on a tablet
hl.window_rule({ name = "float-nm",  match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ name = "float-bt",  match = { class = "blueman-manager" },      float = true })
hl.window_rule({ name = "float-pv",  match = { class = "org.pulseaudio.pavucontrol" }, float = true })
