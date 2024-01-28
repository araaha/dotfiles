#!/bin/bash
bright=$(light -G)
compare="$(echo $bright'<'100 | bc -l)"
single="$(echo $bright'<'10 | bc -l)"
if [[ "$compare" == "1" && "$single" == "0" ]];
then 
    echo $bright | grep -Po "^.."
elif [[ "$compare" == "1" && "$single" == "1" ]]; 
then
    echo $bright | grep -Po "^."
else
    echo $bright | grep -Po "^..."
fi
