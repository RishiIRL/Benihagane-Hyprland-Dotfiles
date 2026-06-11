#!/bin/bash

brightnessctl -s

start=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

for ((p=start; p>=10; p-=5)); do
    current=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

    if (( current > p + 5 )); then
        exit 0
    fi

    brightnessctl set "$p%" -q
    sleep 0.01
done