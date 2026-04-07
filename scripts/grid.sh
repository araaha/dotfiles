#!/bin/bash

GRIDFILE="/tmp/grid_current"
STATEFILE="/tmp/grid_state"

# if argument given, choose new grid
if [ "$1" = "select" ]; then
    GRID=$(printf "4x2\n4x3\n4x4\n6x2\n3x3\n2x2\n" | rofi -dmenu -p "Grid ")
    [ -z "$GRID" ] && exit
    echo "$GRID" > "$GRIDFILE"
fi

# load current grid
if [ -f "$GRIDFILE" ]; then
    GRID=$(cat "$GRIDFILE")
else
    GRID="4x3"
    echo "$GRID" > "$GRIDFILE"
fi

COLS=${GRID%x*}
ROWS=${GRID#*x}

read SW SH <<<$(xdotool getdisplaygeometry)

CW=$((SW / COLS))
RH=$((SH / ROWS))

# load index
if [ -f "$STATEFILE.$GRID" ]; then
    IDX=$(cat "$STATEFILE.$GRID")
else
    IDX=0
fi

COL=$((IDX % COLS))
ROW=$((IDX / COLS))

X=$((COL * CW))
Y=$((ROW * RH))

WIN=$(xdotool selectwindow)

wmctrl -i -r $WIN -e 0,$X,$Y,$CW,$RH

IDX=$((IDX + 1))
TOTAL=$((COLS * ROWS))

if [ $IDX -ge $TOTAL ]; then
    IDX=0
fi

echo $IDX > "$STATEFILE.$GRID"
