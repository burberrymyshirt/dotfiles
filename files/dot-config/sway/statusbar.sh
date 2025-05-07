#!/bin/sh

while :; do
    battery=$(sb-battery)
    datetime=$(date +'%d-%m-%Y %H:%M:%S')
    echo "$battery | $datetime"
    sleep 1
done

