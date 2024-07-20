#!/bin/bash

echo "guided"  | sudo tee /sys/devices/system/cpu/amd_pstate/status
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo "1800000" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
