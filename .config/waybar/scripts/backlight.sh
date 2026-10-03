#!/bin/sh
# Round the reported brightness to the nearest multiple of two percent.
light -G | awk '{ value = int($1 / 2 + 0.5) * 2; if (value < 0) value = 0; if (value > 100) value = 100; print value }'
