---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "us",
        -- Make Caps Lock a compose key (frees a useless key, adds í/ñ/… combos).
        kb_options   = "compose:caps",
        follow_mouse = 1,
        sensitivity  = 0,
        -- Snappier key repeat (matches omarchy's tuning).
        repeat_rate  = 40,
        repeat_delay = 250,
        -- Numpad numbers on by default (useful with an attached keyboard).
        numlock_by_default = true,
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
