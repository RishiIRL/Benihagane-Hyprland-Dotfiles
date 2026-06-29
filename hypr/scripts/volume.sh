#!/usr/bin/env bash

icondir="$HOME/.config/hypr/icons"
duration=1800

read_state() {

    read volume muted <<< "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '
    {
        printf "%d ", $2 * 100

        if ($3 == "[MUTED]")
            print "yes"
        else
            print "no"
    }')"

}

get_icon() {

    if [ "$muted" = "yes" ]; then

        if [ "$volume" -eq 0 ]; then

            echo "$icondir/audio/audio-muted.svg"

        elif [ "$volume" -le 33 ]; then

            echo "$icondir/audio/audio-low-muted.svg"

        elif [ "$volume" -le 66 ]; then

            echo "$icondir/audio/audio-med-muted.svg"

        else

            echo "$icondir/audio/audio-high-muted.svg"

        fi

    else

        if [ "$volume" -eq 0 ]; then

            echo "$icondir/audio/audio-muted.svg"

        elif [ "$volume" -le 33 ]; then

            echo "$icondir/audio/audio-low.svg"

        elif [ "$volume" -le 66 ]; then

            echo "$icondir/audio/audio-med.svg"

        else

            echo "$icondir/audio/audio-high.svg"

        fi

    fi

}

notify() {

    if [ "$1" = "mute" ] && [ "$muted" = "yes" ]; then

        notify-send \
            -e \
            -h string:x-canonical-private-synchronous:volume-osd \
            -u low \
            -i "$icondir/audio/audio-muted.svg" \
            -t "$duration" \
            "Volume" \
            "Muted"

    else

        notify-send \
            -e \
            -h string:x-canonical-private-synchronous:volume-osd \
            -h int:value:$volume \
            -u low \
            -i "$(get_icon)" \
            -t "$duration" \
            "Volume" \
            "${volume}%"

    fi

}

update() {

    case "$1" in

        +)

            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%+

            ;;

        -)

            wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-

            ;;

        mute)

            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

            ;;

        *)

            exit 1

            ;;

    esac


    read_state

    notify "$1"

}

update "$1"