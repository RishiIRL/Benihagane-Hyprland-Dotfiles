hl.layer_rule({
    match = { namespace = "swaync-control-center" },
    blur = true,
    ignore_alpha = 0,
    xray = false,
    dim_around = true,
    animation = "slidefade right 90%"
})

hl.layer_rule({
    match = { namespace = "swaync-notification-window" },
    blur = true,
    ignore_alpha = 0,
    xray = false,
    animation = "slidefade right 90%"
})

hl.layer_rule({
    match = { namespace = "waybar" },
    xray = false
})

hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0,
    xray = false,
    dim_around = true,
    animation = "popin center"
})
