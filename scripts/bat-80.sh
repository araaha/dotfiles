#!/bin/sh
echo "80" | sudo tee /sys/class/power_supply/BATT/charge_control_end_threshold
