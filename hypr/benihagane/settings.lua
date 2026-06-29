hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border = "rgb(d61406)",
            inactive_border = "rgb(2a2a2a)",
        }
    },
    decoration = {
        rounding = 15,
        active_opacity = 0.999,
        dim_special = 0.5,
        blur = {
            enabled = true,
            popups = true,
            size = 7,
            passes = 2,
            noise = 0.1,
            xray = false,
        }
    },
    input = {
        touchpad = {
            natural_scroll = true,
        }
    },
    
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        middle_click_paste = false,
    }
})