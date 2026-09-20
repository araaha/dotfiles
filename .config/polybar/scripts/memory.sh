#!/bin/bash

free -t -m |
    awk '/^Total:/ {
        printf "%.1fG/%.1fG\n", $3 / 1024, $2 / 1024
    }'
