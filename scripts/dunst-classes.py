#!/usr/bin/python3

import subprocess

proc = subprocess.Popen("echo $(calcurse -n)",shell=True,stdout=subprocess.PIPE)


event = proc.communicate()[0].decode('ascii')

if event == "\n":
    exit()

time_remaining = event[19:24]

def convert_to_seconds(arg):
    return int(arg[:2]) * 60 + int(arg[3:])

time = convert_to_seconds(time_remaining)

TIME_END   = 60
TIME_START = 10

if TIME_START <= time <= TIME_END:
    subprocess.run('notify-send -t 3500 "$(calcurse -n)"', shell=True)

