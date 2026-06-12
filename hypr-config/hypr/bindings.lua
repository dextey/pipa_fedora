---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "alacritty"
local fileManager = "nautilus"
local menu        = "rofi -show drun"
local browser     = "firefox"

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
-- Super+L: screen OFF (wakes on touch). NOT hyprlock — the Wayland session-lock
-- protocol blocks the on-screen keyboard, which would trap a keyboard-less tablet.
hl.bind(mainMod .. " + L",             hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
hl.bind(mainMod .. " + M",             hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/power-menu.sh"))  -- compact rofi power menu
-- Physical power button: screen off (NOT lock/shutdown; logind set to ignore it)
hl.bind("XF86PowerOff",                hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
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
