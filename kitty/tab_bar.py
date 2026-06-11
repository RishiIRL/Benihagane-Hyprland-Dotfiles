import math
from pathlib import Path
from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_tab_with_separator,
)

opts = get_options()

primary = as_rgb(int("D61406", 16))
surface1 = as_rgb(int("6e6e6e", 16))
base = as_rgb(int("121212", 16))
window_icon = ""
layout_icon = ""
active_tab_layout_name = ""
active_tab_num_windows = 1
left_status_length = 0


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global active_tab_layout_name
    global active_tab_num_windows

    if tab.is_active:
        active_tab_layout_name = tab.layout_name
        active_tab_num_windows = tab.num_windows

    draw_tab_with_separator(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )

    return screen.cursor.x

def truncate_str(input_str, max_length):
    if len(input_str) > max_length:
        half = max_length // 2
        return input_str[:half] + "…" + input_str[-half:]
    else:
        return input_str


def get_cwd():
    cwd = ""
    tab_manager = get_boss().active_tab_manager
    if tab_manager is not None:
        window = tab_manager.active_window
        if window is not None:
            cwd = window.cwd_of_child

    cwd_parts = list(Path(cwd).parts)
    if len(cwd_parts) > 1:
        if cwd_parts[1] == "home":
            # replace /home/{{username}}
            cwd_parts = ["~"] + cwd_parts[3:]
            if len(cwd_parts) > 1:
                cwd_parts[0] = "~/"
        else:
            cwd_parts[0] = "/"
    else:
        cwd_parts[0] = "/"

    max_length = 10
    if len(cwd_parts) < 3:
        cwd = cwd_parts[0] + "/".join(
            [
                s if len(s) <= max_length else truncate_str(s, max_length)
                for s in cwd_parts[1:]
            ]
        )
    else:
        cwd = "…/" + "/".join(
            [
                s if len(s) <= max_length else truncate_str(s, max_length)
                for s in cwd_parts[-2:]
            ]
        )

    return cwd