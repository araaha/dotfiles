#!/bin/bash

LATITUDE="43.5168"
LONGITUDE="-79.8829"
TIMEZONE="America/Toronto"
API="https://api.open-meteo.com/v1/forecast"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-weather"

fallback() {
    [[ -r "$CACHE" ]] && cat "$CACHE" || echo "Weather unavailable"
    exit 0
}

if ! weather=$(curl -fs --get \
    --connect-timeout 2 \
    --max-time 5 \
    "$API" \
    --data-urlencode "latitude=$LATITUDE" \
    --data-urlencode "longitude=$LONGITUDE" \
    --data-urlencode "current=temperature_2m,apparent_temperature,precipitation_probability" \
    --data-urlencode "daily=sunset" \
    --data-urlencode "timezone=$TIMEZONE" \
    --data-urlencode "forecast_days=1"); then
    fallback
fi

read -r temp feels rain sunset < <(
    jq -er '
        [
            .current.temperature_2m,
            .current.apparent_temperature,
            .current.precipitation_probability,
            .daily.sunset[0]
        ]
        | if any(.[]; . == null)
          then error("missing data")
          else @tsv
          end
    ' <<< "$weather"
) || fallback

printf -v temp '%.0f' "$temp"
printf -v feels '%.0f' "$feels"

[[ $temp == -0 ]] && temp=0
[[ $feels == -0 ]] && feels=0

sunset="${sunset#*T}"
sunset="${sunset:0:5}"

output="$temp° ($feels°) $sunset"
(( rain > 0 )) && output+=" [$rain%]"

printf '%s\n' "$output" | tee "$CACHE"

