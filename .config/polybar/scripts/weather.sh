#!/bin/bash

set -o pipefail

LATITUDE="43.5168"
LONGITUDE="-79.8829"
TIMEZONE="America/Toronto"
SYMBOL="°"

API="https://api.open-meteo.com/v1/forecast"

get_icon() {
    local code="$1"
    local is_day="$2"
    local icon

    case "$code" in
        0)
            (( is_day )) && icon="" || icon=""
            ;;
        1|2)
            (( is_day )) && icon="" || icon=""
            ;;
        3)
            icon=""
            ;;
        45|48)
            (( is_day )) && icon="" || icon=""
            ;;
        51|53|55|56|57|80|81|82)
            icon=""
            ;;
        61|63|65|66|67)
            (( is_day )) && icon="" || icon=""
            ;;
        71|73|75|77|85|86)
            (( is_day )) && icon="" || icon=""
            ;;
        95|96|99)
            (( is_day )) && icon="" || icon=""
            ;;
        *)
            icon=""
            ;;
    esac

    printf '%s\n' "$icon"
}

round_temperature() {
    local rounded

    rounded=$(LC_NUMERIC=C printf '%.0f' "$1")

    if [[ $rounded == "-0" ]]; then
        rounded=0
    fi

    printf '%s\n' "$rounded"
}

if ! weather=$(
    curl \
        --fail \
        --silent \
        --show-error \
        --get \
        --connect-timeout 5 \
        --max-time 15 \
        --retry 2 \
        "$API" \
        --data-urlencode "latitude=$LATITUDE" \
        --data-urlencode "longitude=$LONGITUDE" \
        --data-urlencode \
            "current=temperature_2m,apparent_temperature,weather_code,is_day,precipitation_probability" \
        --data-urlencode "daily=sunset" \
        --data-urlencode "timezone=$TIMEZONE" \
        --data-urlencode "forecast_days=1"
); then
    echo "Unable to retrieve weather data." >&2
    exit 1
fi

if ! weather_values=$(
    jq -er '
        [
            .current.temperature_2m,
            .current.apparent_temperature,
            .current.weather_code,
            .current.is_day,
            .current.precipitation_probability,
            .daily.sunset[0]
        ]
        | if any(.[]; . == null)
          then error("Missing weather data")
          else @tsv
          end
    ' <<<"$weather"
); then
    echo "Open-Meteo returned incomplete weather data." >&2
    exit 1
fi

IFS=$'\t' read -r \
    weather_temp \
    weather_feels_like \
    weather_code \
    is_day \
    precipitation_probability \
    sunset <<<"$weather_values"

weather_temp=$(round_temperature "$weather_temp")
weather_feels_like=$(round_temperature "$weather_feels_like")

# Sunset is returned as YYYY-MM-DDTHH:MM.
sunset_time="${sunset#*T}"
sunset_time="${sunset_time:0:5}"

printf '%s %s%s (%s%s) %s [%s%%]\n' \
    "$(get_icon "$weather_code" "$is_day")" \
    "$weather_temp" "$SYMBOL" \
    "$weather_feels_like" "$SYMBOL" \
    "$sunset_time" \
    "$precipitation_probability"
