#!/usr/bin/env bash
# =============================================================================
# network.sh — Rofi + nmcli network manager
# =============================================================================

# ---------------------------------------------------------------------------
# Devices
# ---------------------------------------------------------------------------
WIFI_DEV="wlo1"
ETH_DEV="eno2"

# ---------------------------------------------------------------------------
# Rofi themes (set to "" to use rofi's default theme)
# ---------------------------------------------------------------------------
ROFI_THEME_WIFI="${HOME}/.config/rofi/network/wifi-list.rasi"
ROFI_THEME_ACTIONS="${HOME}/.config/rofi/network/actions.rasi"
ROFI_THEME_PASSWORD="${HOME}/.config/rofi/network/password.rasi"

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
ENABLED_COLOR="#A3BE8C"
DISABLED_COLOR="#D35F5E"

# ---------------------------------------------------------------------------
# Icons
# ---------------------------------------------------------------------------
SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")
SECURED_SIGNAL_ICONS=("󰤡 " "󰤤 " "󰤧 " "󰤪 ")
CONNECTED_ICON=""     # shown to the RIGHT of SSID

# ---------------------------------------------------------------------------
# Helper: pick the correct signal icon
#   $1 = signal (0-100)   $2 = security string
# ---------------------------------------------------------------------------
_signal_icon() {
    local signal="${1:-0}"
    local security="${2:-}"
    local level=$(( signal / 25 ))
    (( level > 3 )) && level=3
    if [[ "$security" =~ WPA|WEP ]]; then
        echo "${SECURED_SIGNAL_ICONS[$level]}"
    else
        echo "${SIGNAL_ICONS[$level]}"
    fi
}

# ---------------------------------------------------------------------------
# get_status — one-line status for a bar (polybar / waybar / etc.)
# ---------------------------------------------------------------------------
get_status() {
    local status_icon status_color

    if nmcli -t -f TYPE,STATE device status | grep -q 'ethernet:connected'; then
        status_icon="󰈀"
        status_color="$ENABLED_COLOR"

    elif nmcli -t -f TYPE,STATE device status | grep -q 'wifi:connected'; then
        local wifi_info
        wifi_info=$(nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" \
                        device wifi list --rescan no | grep '^\*')
        if [[ -n "$wifi_info" ]]; then
            IFS=: read -r _in_use signal security _ssid <<< "$wifi_info"
            status_icon="$(_signal_icon "$signal" "$security")"
            status_color="$ENABLED_COLOR"
        else
            status_icon=" "
            status_color="$DISABLED_COLOR"
        fi

    else
        status_icon=" "
        status_color="$DISABLED_COLOR"
    fi

    local session="${XDG_SESSION_TYPE:-}"
    if [[ "$session" == "wayland" ]]; then
        echo "<span color=\"$status_color\">$status_icon</span>"
    else
        echo "%{F$status_color}$status_icon%{F-}"
    fi
}

# ---------------------------------------------------------------------------
# _rofi_theme — emit "-theme <path>" only when the file exists
#   $1 = theme file path
# ---------------------------------------------------------------------------
_rofi_theme() {
    [[ -f "$1" ]] && echo "-theme $1"
}

# ---------------------------------------------------------------------------
# password_dialog — masked password entry
#   Network info (SSID / security / signal) shown in rofi's -mesg block,
#   keeping the -p prompt label clean.
#   $1 = SSID   $2 = security   $3 = signal (0-100)
#   Prints the entered password on stdout; returns 1 if cancelled.
# ---------------------------------------------------------------------------
password_dialog() {
    local ssid="$1"
    local security="$2"
    local signal="$3"

    local mesg
    mesg=$'SSID: '"${ssid}"$'\nSecurity: '"${security}"$'\nSignal: '"${signal}"$'%'

    local password
    # shellcheck disable=SC2046
    password=$(rofi $(_rofi_theme "$ROFI_THEME_PASSWORD") \
        -dmenu -password -lines 0 \
        -p " Password" \
        -mesg "$mesg")

    [[ -z "$password" ]] && return 1
    echo "$password"
}

# ---------------------------------------------------------------------------
# wifi_actions — action menu for a selected SSID
#   $1 = SSID   $2 = security   $3 = signal   $4 = is_active (true|false)
# ---------------------------------------------------------------------------
wifi_actions() {
    local ssid="$1"
    local security="$2"
    local signal="$3"
    local is_active="$4"

    # Build per-network saved-profile check once
    local has_saved=false
    if nmcli -g NAME connection show | grep -Fxq "$ssid"; then
        has_saved=true
    fi

    while true; do
        # ---- Build option list ----
        local options="󰁍 Back"
        if [[ "$is_active" == "true" ]]; then
            options+=$'\n'' Disconnect'
        else
            options+=$'\n''󰸋 Connect'
        fi
        if [[ "$has_saved" == "true" ]]; then
            options+=$'\n''󰘥 Forget'
        fi

        local action
        # shellcheck disable=SC2046
        action=$(echo "$options" | rofi $(_rofi_theme "$ROFI_THEME_ACTIONS") -dmenu -p "  ${ssid}: ")
        [[ -z "$action" ]] && return   # rofi closed

        case "$action" in

            "󰁍 Back")
                return
                ;;

            "󰸋 Connect")
                _do_connect "$ssid" "$security" "$signal"
                # After connect attempt, refresh is_active for the loop
                if nmcli -t -f NAME connection show --active | grep -Fxq "$ssid"; then
                    is_active=true
                    has_saved=true
                fi
                ;;

            " Disconnect")
                if nmcli device disconnect "$WIFI_DEV"; then
                    notify-send "Disconnected" "Disconnected from \"${ssid}\"."
                fi
                is_active=false
                return
                ;;

            "󰘥 Forget")
                if nmcli connection delete id "$ssid"; then
                    notify-send "Forgotten" "Profile for \"${ssid}\" removed."
                    has_saved=false
                fi
                return
                ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# _do_connect — internal: attempt connection, handle retry on failure
#   $1 = SSID   $2 = security   $3 = signal
# ---------------------------------------------------------------------------
_do_connect() {
    local ssid="$1"
    local security="$2"
    local signal="$3"

    # Saved profile → just bring it up
    if nmcli -g NAME connection show | grep -Fxq "$ssid"; then
        local err
        err=$(nmcli connection up id "$ssid" 2>&1)
        if echo "$err" | grep -qi "successfully"; then
            notify-send "Connected" "Connected to \"${ssid}\"."
        else
            _connection_failed_dialog "$ssid" "$security" "$signal" "$err"
        fi
        return
    fi

    # Unsaved — open / secured needs a password
    if [[ "$security" =~ WPA|WEP ]]; then
        _connect_with_password "$ssid" "$security" "$signal"
    else
        local err
        err=$(nmcli device wifi connect "$ssid" 2>&1)
        if echo "$err" | grep -qi "successfully"; then
            notify-send "Connected" "Connected to \"${ssid}\"."
        else
            _connection_failed_dialog "$ssid" "$security" "$signal" "$err"
        fi
    fi
}

# ---------------------------------------------------------------------------
# _connect_with_password — prompt for password and attempt connection
#   Loops on failure until user chooses Back.
# ---------------------------------------------------------------------------
_connect_with_password() {
    local ssid="$1"
    local security="$2"
    local signal="$3"

    while true; do
        local password
        password=$(password_dialog "$ssid" "$security" "$signal") || return
	
	notify-send \
    		-a "Network Manager" \
   		"Connecting..." \
    		"Attempting to connect to $ssid"

        local err
        err=$(nmcli device wifi connect "$ssid" password "$password" 2>&1)
        if echo "$err" | grep -qi "successfully"; then
            notify-send "Connected" "Connected to \"${ssid}\"."
            return
        fi

        # Strip the nmcli prefix for a cleaner error
        local clean_err
        clean_err=$(echo "$err" | sed 's/Error: //')
        _connection_failed_dialog "$ssid" "$security" "$signal" "$clean_err" || return
    done
}

# ---------------------------------------------------------------------------
# _connection_failed_dialog — show failure, offer Retry / Back
#   Returns 0 to retry, 1 to go back.
# ---------------------------------------------------------------------------
_connection_failed_dialog() {
    local ssid="$1"
    local security="$2"
    local signal="$3"
    local error_msg="$4"

    local choice
    # shellcheck disable=SC2046
    choice=$(printf "󰑐 Retry\n󰁍 Back" | \
        rofi $(_rofi_theme "$ROFI_THEME_ACTIONS") -dmenu -p "✗ Failed" \
        -mesg "${error_msg}" -lines 2)

    case "$choice" in
        "󰑐 Retry")
            if [[ "$security" =~ WPA|WEP ]]; then
                _connect_with_password "$ssid" "$security" "$signal"
            else
                _do_connect "$ssid" "$security" "$signal"
            fi
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# wifi_menu — Wi-Fi list with fixed header entries
# ---------------------------------------------------------------------------
wifi_menu() {
    while true; do
        # ---- Toggle label ----
        local wifi_status wifi_toggle wifi_toggle_cmd
        wifi_status=$(nmcli -fields WIFI g)
        if [[ "$wifi_status" =~ enabled ]]; then
            wifi_toggle="󱛅  Disable Wi-Fi"
            wifi_toggle_cmd="off"
        else
            wifi_toggle="󱚽  Enable Wi-Fi"
            wifi_toggle_cmd="on"
        fi

        # ---- Scan & deduplicate ----
        # Columns: IN-USE : SIGNAL : SECURITY : SSID
        local raw_list
        raw_list=$(nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" \
                       device wifi list --rescan no)

        declare -A seen_ssids        # dedup map
        local entries=()             # parallel arrays
        local ssids=()
        local securities=()
        local signals=()
        local active_ssid=""

        while IFS= read -r line; do
            # nmcli --terse uses : as delimiter but SSID can contain colons;
            # use cut only for the first 3 fields, take the rest as SSID.
            local in_use signal security ssid
            in_use=$(echo "$line"   | cut -d: -f1)
            signal=$(echo "$line"   | cut -d: -f2)
            security=$(echo "$line" | cut -d: -f3)
            ssid=$(echo "$line"     | cut -d: -f4-)

            [[ -z "$ssid" ]] && continue
            [[ -n "${seen_ssids[$ssid]}" ]] && continue
            seen_ssids["$ssid"]=1

            local icon
            icon=$(_signal_icon "$signal" "$security")

            local entry="${icon}${ssid}"
            if [[ "$in_use" =~ \* ]]; then
                active_ssid="$ssid"
                entry="${entry}  ${CONNECTED_ICON}"
            fi

            entries+=("$entry")
            ssids+=("$ssid")
            securities+=("$security")
            signals+=("$signal")
        done <<< "$raw_list"

        # ---- Build rofi list ----
        local menu_header
        menu_header="󰁍 Back"$'\n'"󰑐 Refresh Wi-Fi List"$'\n'"${wifi_toggle}"

        local network_block
        network_block=$(printf '%s\n' "${entries[@]}")

        local full_menu
        if [[ -n "$network_block" ]]; then
            full_menu="${menu_header}"$'\n'"${network_block}"
        else
            full_menu="${menu_header}"
        fi

        local chosen
        # shellcheck disable=SC2046
        chosen=$(echo "$full_menu" | rofi $(_rofi_theme "$ROFI_THEME_WIFI") -a 0,1,2 -dmenu -i -p "󱖗 Wi-Fi: ")
        [[ -z "$chosen" ]] && return

        # ---- Handle fixed entries ----
        case "$chosen" in
            "󰁍 Back")
                return
                ;;
            "󰑐 Refresh Wi-Fi List")
                nmcli device wifi rescan 2>/dev/null
                unset seen_ssids
                declare -A seen_ssids
                continue
                ;;
            "$wifi_toggle")
                nmcli radio wifi "$wifi_toggle_cmd"
                continue
                ;;
        esac

        # ---- Match chosen entry back to SSID ----
        local matched_idx=-1
        for i in "${!entries[@]}"; do
            if [[ "${entries[$i]}" == "$chosen" ]]; then
                matched_idx=$i
                break
            fi
        done
        [[ $matched_idx -lt 0 ]] && continue

        local sel_ssid="${ssids[$matched_idx]}"
        local sel_security="${securities[$matched_idx]}"
        local sel_signal="${signals[$matched_idx]}"
        local sel_active=false
        [[ "$sel_ssid" == "$active_ssid" ]] && sel_active=true

        wifi_actions "$sel_ssid" "$sel_security" "$sel_signal" "$sel_active"
        unset seen_ssids
        declare -A seen_ssids
    done
}

# ---------------------------------------------------------------------------
# ethernet_menu
# ---------------------------------------------------------------------------
ethernet_menu() {
    while true; do
        # Check physical carrier
        local carrier
        carrier=$(cat "/sys/class/net/${ETH_DEV}/carrier" 2>/dev/null)

        if [[ "$carrier" != "1" ]]; then
            local choice
            # shellcheck disable=SC2046
            choice=$(printf '󰁍 Back\n󰈂 No Ethernet Cable' | \
                rofi $(_rofi_theme "$ROFI_THEME_ACTIONS") -dmenu -i -p " Ethernet (${ETH_DEV}): ")
            [[ "$choice" == "󰁍 Back" || -z "$choice" ]] && return
            continue
        fi

        # Check connected state (100 = connected)
        local device_state
        device_state=$(nmcli -t -f GENERAL.STATE device show "$ETH_DEV" 2>/dev/null \
                       | grep 'GENERAL.STATE' | cut -d: -f2)

        local toggle_label
        if [[ "$device_state" =~ ^100 ]]; then
            toggle_label=" Disconnect"
        else
            toggle_label="󰈀 Connect"
        fi

        local action
        # shellcheck disable=SC2046
        action=$(printf '󰁍 Back\n%s' "$toggle_label" | \
            rofi $(_rofi_theme "$ROFI_THEME_ACTIONS") -dmenu -i -p " Ethernet (${ETH_DEV}): ")
        [[ -z "$action" ]] && return

        case "$action" in
            "󰁍 Back")
                return
                ;;
            "󰈀 Connect")
                if nmcli device connect "$ETH_DEV"; then
                    notify-send "Connected" "${ETH_DEV} connected."
                fi
                ;;
            " Disconnect")
                if nmcli device disconnect "$ETH_DEV"; then
                    notify-send "Disconnected" "${ETH_DEV} disconnected."
                fi
                ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# main_menu
# ---------------------------------------------------------------------------
main_menu() {
    # ---- Parse flags ----
    local status_mode=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --status)
                status_mode=true
                shift
                ;;
            --enabled-color)
                ENABLED_COLOR="$2"
                shift 2
                ;;
            --disabled-color)
                DISABLED_COLOR="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [[ "$status_mode" == "true" ]]; then
        get_status
        exit 0
    fi

    # ---- Ensure NetworkManager is running ----
    if ! pgrep -x NetworkManager > /dev/null; then
        echo -n "Root Password: "
        read -rs password
        echo
        echo "$password" | sudo -S systemctl start NetworkManager
    fi

    # ---- Menu loop ----
    while true; do
        local chosen
        # shellcheck disable=SC2046
        chosen=$(printf '󱛁 Wi-Fi\n󰈀 Ethernet' | \
            rofi $(_rofi_theme "$ROFI_THEME_ACTIONS") -dmenu -i -p "󱖗  Network")
        [[ -z "$chosen" ]] && return

        case "$chosen" in
            "󱛁 Wi-Fi")    wifi_menu     ;;
            "󰈀 Ethernet") ethernet_menu ;;
        esac
    done
}

main_menu "$@"