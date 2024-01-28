#!/bin/bash
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
notify-send -t 250 "Performance"
