#!/bin/bash

total=$(free -t -m | awk '{print $2}' | tail -1)
res_tot=$(echo "scale=1; $total / 1024" | bc)

used=$(free -t -m | awk '{print $3}' | tail -1)
res_used=$(echo "scale=1; $used / 1024" | bc)

if (( $(echo "$used < 1000" | bc -l) )); then
    echo 0"$res_used"G/"$res_tot"G
else
    echo "$res_used"G/"$res_tot"G
fi
