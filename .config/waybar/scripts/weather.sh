#!/bin/sh

latitude="43.5168"
longitude="-79.8829"
timezone="America/Toronto"
api="https://api.open-meteo.com/v1/forecast"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-weather"

render() {
    # Use proportional separators; Meslo's monospace cells keep thin spaces wide.
    sed 's/[  ]/<span font_family="sans-serif" size="small"> <\/span>/g'
}

fallback() {
    if [ -r "$cache" ]; then
        render < "$cache"
    else
        printf '%s\n' "Weather unavailable"
    fi
    exit 0
}

weather=$(curl -fs --get \
    --connect-timeout 2 \
    --max-time 5 \
    "$api" \
    --data-urlencode "latitude=$latitude" \
    --data-urlencode "longitude=$longitude" \
    --data-urlencode "current=temperature_2m,apparent_temperature,weather_code" \
    --data-urlencode "daily=sunset" \
    --data-urlencode "timezone=$timezone" \
    --data-urlencode "forecast_days=1") || fallback

values=$(printf '%s\n' "$weather" | jq -er '
    [
        .current.temperature_2m,
        .current.apparent_temperature,
        .current.weather_code,
        .daily.sunset[0]
    ]
    | if any(.[]; . == null)
      then error("missing data")
      else @tsv
      end
') || fallback

IFS="$(printf '\t')" read -r temp feels code sunset <<EOF
$values
EOF

temp=$(printf '%.0f' "$temp")
feels=$(printf '%.0f' "$feels")
[ "$temp" = "-0" ] && temp=0
[ "$feels" = "-0" ] && feels=0

sunset=${sunset#*T}
sunset=$(printf '%.5s' "$sunset")
condition=""
case "$code" in
    51|53|55)             condition="Drizzle" ;;
    56|57)                condition="Freezing drizzle" ;;
    61|63|65)             condition="Rain" ;;
    66|67)                condition="Freezing rain" ;;
    71|73|75|77|85|86)    condition="Snow" ;;
    80|81|82)             condition="Showers" ;;
    95|96|97|99)          condition="Thunderstorm" ;;
esac

output="$temp° ($feels°) $sunset"
[ -n "$condition" ] && output="$output $condition"

printf '%s\n' "$output" | tee "$cache" | render
