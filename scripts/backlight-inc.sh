#!/bin/bash
bright="$(light -G)"
if (( $(echo "13 > $bright" | bc -l) ));
then
	light -A 1
else
	light -A 2
fi




