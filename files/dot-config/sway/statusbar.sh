#!/bin/sh

while :; do
    keyboard_layout=$(sb-sway-keyboard)
    battery=$(sb-battery)
    datetime=$(date +'%d-%m-%Y %H:%M:%S')
    echo "$keyboard_layout | $battery | $datetime"
    sleep 1
done

