--Variables
local mainMod = "SUPER"
local TERMINAL = "kitty"
local BROWSER = "zen"
local BROWSER_ALT = "chromium-browser"
local EXPLORER = "nautilus"
local EDITOR = "code"
local KILLACTIVE = "hyprctl dispatch killactive"

-- Apps
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(TERMINAL), { description = "Open Terminal" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(BROWSER), { description = "Open Browser" })
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(BROWSER_ALT), { description = "Open Alternative Browser" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(EXPLORER), { description = "Open File Explorer" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(EDITOR), { description = "Open Code Editor" })

-- Rofi
hl.bind(
	mainMod .. " + Space",
	hl.dsp.exec_cmd("killall rofi || rofi -show drun -show-icons"),
	{ description = "Toggle Application Launcher" }
)
hl.bind(
	mainMod .. " + V",
	hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"),
	{ description = "Open Clipboard History" }
)
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/powermenu.sh"), { description = "Power Menu" })

-- Window Management
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close Window" })
hl.bind("ALT + F4", hl.dsp.window.kill(), { description = "Kill Window" })
hl.bind(mainMod .. " + W", hl.dsp.window.float(), { description = "Toggle Floating" })
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen(), { description = "Toggle Fullscreen" })

-- Group Management
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle Group" })
hl.bind(mainMod .. " + CONTROL + Left", hl.dsp.group.prev(), { description = "Previous Window in that group" })
hl.bind(mainMod .. " + CONTROL + Right", hl.dsp.group.next(), { description = "Next Window in that group" })

-- Focus
hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }), { description = "Focus Left" })
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }), { description = "Focus Right" })
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }), { description = "Focus Up" })
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }), { description = "Focus Down" })
hl.bind(
	"ALT + Tab",
	hl.dsp.exec_cmd('hyprctl --batch "dispatch cyclenext ; dispatch ALTerzorder top"'),
	{ description = "Focus Cycle" }
)

-- Resize Windows with mainMod + SHIFT + [←→↑↓]
hl.bind(
	mainMod .. " + SHIFT + Right",
	hl.dsp.window.resize({ x = "30", y = "0", relative = true }),
	{ description = "Resize Window Right", repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + Left",
	hl.dsp.window.resize({ x = "-30", y = "0", relative = true }),
	{ description = "Resize Window Left", repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + Up",
	hl.dsp.window.resize({ x = "0", y = "-30", relative = true }),
	{ description = "Resize Window Up", repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + Down",
	hl.dsp.window.resize({ x = "0", y = "30", relative = true }),
	{ description = "Resize Window Down", repeating = true }
)

-- Move active window around current workspace with mainMod + SHIFT + CONTROL [←→↑↓]
hl.bind(
	mainMod .. " + SHIFT + CONTROL + Right",
	hl.dsp.window.swap({ direction = "right" }),
	{ description = "Move Window Right" }
)
hl.bind(
	mainMod .. " + SHIFT + CONTROL + Left",
	hl.dsp.window.swap({ direction = "left" }),
	{ description = "Move Window Left" }
)
hl.bind(
	mainMod .. " + SHIFT + CONTROL + Up",
	hl.dsp.window.swap({ direction = "up" }),
	{ description = "Move Window Up" }
)
hl.bind(
	mainMod .. " + SHIFT + CONTROL + Down",
	hl.dsp.window.swap({ direction = "down" }),
	{ description = "Move Window Down" }
)

-- Move/Resize focused window with Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { description = "Move Window with Mouse" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { description = "Resize Window with Mouse" })

-- Workspace Navigation
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = "1" }), { description = "Focus Workspace 1" })
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = "2" }), { description = "Focus Workspace 2" })
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = "3" }), { description = "Focus Workspace 3" })
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = "4" }), { description = "Focus Workspace 4" })
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = "5" }), { description = "Focus Workspace 5" })
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = "6" }), { description = "Focus Workspace 6" })
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = "7" }), { description = "Focus Workspace 7" })
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = "8" }), { description = "Focus Workspace 8" })
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = "9" }), { description = "Focus Workspace 9" })
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }), { description = "Focus Workspace 10" })

-- Relative workspace navigation
hl.bind(
	mainMod .. " + CONTROL + Down",
	hl.dsp.focus({ workspace = "r+1" }),
	{ description = "Focus Next Workspace", repeating = true }
)
hl.bind(
	mainMod .. " + CONTROL + Up",
	hl.dsp.focus({ workspace = "r-1" }),
	{ description = "Focus Previous Workspace", repeating = true }
)
hl.bind(mainMod .. " + CONTROL + mouse_up", hl.dsp.focus({ workspace = "r+1" }), { description = "Focus Next Workspace" })
hl.bind(mainMod .. " + CONTROL + mouse_down", hl.dsp.focus({ workspace = "r-1" }), { description = "Focus Previous Workspace" })

-- Move focused window to workspace
hl.bind(
	mainMod .. " + CONTROL + ALT + 1",
	hl.dsp.window.move({ workspace = "1" }),
	{ description = "Move Window to Workspace 1" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 2",
	hl.dsp.window.move({ workspace = "2" }),
	{ description = "Move Window to Workspace 2" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 3",
	hl.dsp.window.move({ workspace = "3" }),
	{ description = "Move Window to Workspace 3" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 4",
	hl.dsp.window.move({ workspace = "4" }),
	{ description = "Move Window to Workspace 4" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 5",
	hl.dsp.window.move({ workspace = "5" }),
	{ description = "Move Window to Workspace 5" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 6",
	hl.dsp.window.move({ workspace = "6" }),
	{ description = "Move Window to Workspace 6" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 7",
	hl.dsp.window.move({ workspace = "7" }),
	{ description = "Move Window to Workspace 7" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 8",
	hl.dsp.window.move({ workspace = "8" }),
	{ description = "Move Window to Workspace 8" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 9",
	hl.dsp.window.move({ workspace = "9" }),
	{ description = "Move Window to Workspace 9" }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + 0",
	hl.dsp.window.move({ workspace = "10" }),
	{ description = "Move Window to Workspace 10" }
)

-- Move focused window to next/previous workspace
hl.bind(
	mainMod .. " + CONTROL + ALT + Down",
	hl.dsp.window.move({ workspace = "r+1" }),
	{ description = "Move Window to Next Workspace on monitor", repeating = true }
)
hl.bind(
	mainMod .. " + CONTROL + ALT + Up",
	hl.dsp.window.move({ workspace = "r-1" }),
	{ description = "Move Window to Previous Workspace on monitor", repeating = true }
)

-- Move focused window to a workspace silently (without switching to that workspace) (ToDO)
hl.bind(
	mainMod .. " + ALT + 1",
	hl.dsp.window.move({ workspace = "1", follow = false }),
	{ description = "Move Window to Workspace 1 silently" }
)
hl.bind(
	mainMod .. " + ALT + 2",
	hl.dsp.window.move({ workspace = "2", follow = false }),
	{ description = "Move Window to Workspace 2 silently" }
)
hl.bind(
	mainMod .. " + ALT + 3",
	hl.dsp.window.move({ workspace = "3", follow = false }),
	{ description = "Move Window to Workspace 3 silently" }
)
hl.bind(
	mainMod .. " + ALT + 4",
	hl.dsp.window.move({ workspace = "4", follow = false }),
	{ description = "Move Window to Workspace 4 silently" }
)
hl.bind(
	mainMod .. " + ALT + 5",
	hl.dsp.window.move({ workspace = "5", follow = false }),
	{ description = "Move Window to Workspace 5 silently" }
)
hl.bind(
	mainMod .. " + ALT + 6",
	hl.dsp.window.move({ workspace = "6", follow = false }),
	{ description = "Move Window to Workspace 6 silently" }
)
hl.bind(
	mainMod .. " + ALT + 7",
	hl.dsp.window.move({ workspace = "7", follow = false }),
	{ description = "Move Window to Workspace 7 silently" }
)
hl.bind(
	mainMod .. " + ALT + 8",
	hl.dsp.window.move({ workspace = "8", follow = false }),
	{ description = "Move Window to Workspace 8 silently" }
)
hl.bind(
	mainMod .. " + ALT + 9",
	hl.dsp.window.move({ workspace = "9", follow = false }),
	{ description = "Move Window to Workspace 9 silently" }
)
hl.bind(
	mainMod .. " + ALT + 0",
	hl.dsp.window.move({ workspace = "10", follow = false }),
	{ description = "Move Window to Workspace 10 silently" }
)

-- Special Workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle Scratchpad" })
hl.bind(
	mainMod .. " + CONTROL + ALT + S",
	hl.dsp.window.move({ workspace = "special:scratchpad" }),
	{ description = "Move Window to Scratchpad" }
)

-- Audio CONTROLs
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh +"),
	{ description = "Increase Volume", repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh -"),
	{ description = "Decrease Volume", repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"), { description = "Toggle Mute" })

-- Brightness CONTROLs
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl set +5%"),
	{ description = "Increase Brightness", repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl set 5%-"),
	{ description = "Decrease Brightness", repeating = true }
)

-- Media CONTROLs
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play/Pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { description = "Next Track", repeating = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { description = "Previous Track", repeating = true })

-- Session Management
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"), { description = "Lock Screen" })
hl.bind(mainMod .. " + Delete", hl.dsp.exec_cmd("hyprshutdown"), { description = "Logout" })
hl.bind(
	mainMod .. " + ALT + W",
	hl.dsp.exec_cmd("pgrep waybar && killall waybar || waybar"),
	{ description = "Toggle Waybar" }
)

-- Screenshot
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))

-- OPAQUE Mode
hl.bind(mainMod .. " + F2", function()
	local opaque_mode = (hl.get_config("decoration.active_opacity") == 1.0)

	if opaque_mode then
		hl.exec_cmd("hyprctl reload")
		return
	end
	hl.notification.create({ text = "Opaque Mode Activated", duration = 3000, color = "rgb(214, 20, 6)", icon = "ok" })
	hl.config({
		decoration = {
			active_opacity = 1.0, -- Make active windows fully opaque
			inactive_opacity = 1.0, -- Make inactive windows fully opaque
		},
	})
	hl.window_rule({
		match = { float = false },
		opaque = true,
	})
	hl.window_rule({
		match = { float = true },
		opaque = true,
	})
end)

-- No Distractions Mode
hl.bind(mainMod .. " + F1", function()
	local game_mode = (hl.get_config("animations.enabled") == false)

	if game_mode then
		hl.exec_cmd("hyprctl reload")
		return
	end
	hl.notification.create({
		text = "No Distractions Mode Activated",
		duration = 3000,
		color = "rgb(214, 20, 6)",
		icon = "ok",
	})
	hl.config({
		general = {
			gaps_in = 0,
			gaps_out = 0, -- Disable gaps
			border_size = 0,
		},

		animations = {
			enabled = false, -- Disable animations
		},

		-- Disable blur, shadow and window rounding
		decoration = {
			shadow = { enabled = false },
			blur = { enabled = false },
			rounding = 0,
			active_opacity = 1.0, -- Make active windows fully opaque
			inactive_opacity = 1.0, -- Make inactive windows fully opaque
			dim_special = 0, -- Disable dimming of special windows
		},
	})
	hl.window_rule({
		match = { float = false },
		opaque = true,
	})
	hl.window_rule({
		match = { float = true },
		opaque = true,
	})
end)

