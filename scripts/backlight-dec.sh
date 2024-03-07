#!/bin/bash

bright="$(light -G)"

if (( $(echo "17 > $bright" | bc -l) ));
then
	light -U 1
else
	light -U 2
fi
