#!/bin/bash

set -o pipefail

get_icon() {
    case "$1" in
        01d) icon="" ;;
        01n) icon="" ;;
        02d) icon="" ;;
        02n) icon="" ;;
        03*) icon="" ;;
        04*) icon="" ;;
        09*) icon="" ;;
        10d) icon="" ;;
        10n) icon="" ;;
        11d) icon="" ;;
        11n) icon="" ;;
        13d) icon="" ;;
        13n) icon="" ;;
        50d) icon="" ;;
        50n) icon="" ;;
        *)   icon="" ;;
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

CITY="${1:-}"
UNITS="metric"
SYMBOL="°"
API="https://api.openweathermap.org/data/2.5"

if [[ -z $CITY ]]; then
    printf 'Usage: %s CITY_OR_ID\n' "$0" >&2
    exit 1
fi

if ! KEY=$(pass OpenWeather); then
    echo "Unable to retrieve the OpenWeather API key from pass." >&2
    exit 1
fi

if [[ -z $KEY ]]; then
    echo "The OpenWeather password-store entry is empty." >&2
    exit 1
fi

curl_args=(
    --fail
    --silent
    --show-error
    --get
    --connect-timeout 5
    --max-time 15
    --retry 2
    "$API/weather"
    --data-urlencode "appid=$KEY"
    --data-urlencode "units=$UNITS"
)

if [[ $CITY =~ ^[0-9]+$ ]]; then
    curl_args+=(--data-urlencode "id=$CITY")
else
    curl_args+=(--data-urlencode "q=$CITY")
fi

if ! weather=$(curl "${curl_args[@]}"); then
    echo "Unable to retrieve weather data." >&2
    exit 1
fi

if ! weather_values=$(
    jq -er '
        [
            .main.temp,
            .main.feels_like,
            .sys.sunset,
            .weather[0].icon
        ]
        | if any(.[]; . == null)
          then error("Missing weather data")
          else @tsv
          end
    ' <<<"$weather"
); then
    echo "OpenWeather returned incomplete or invalid data." >&2
    exit 1
fi

IFS=$'\t' read -r \
    weather_temp \
    weather_feels_like \
    sunset \
    weather_icon <<<"$weather_values"

weather_temp=$(round_temperature "$weather_temp")
weather_feels_like=$(round_temperature "$weather_feels_like")
sunset_time=$(date -d "@$sunset" '+%H:%M')

printf '%s %s%s (%s%s) %s\n' \
    "$(get_icon "$weather_icon")" \
    "$weather_temp" "$SYMBOL" \
    "$weather_feels_like" "$SYMBOL" \
    "$sunset_time"
