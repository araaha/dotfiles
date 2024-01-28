#!/bin/bash

echo "$(calcurse -n | sed 1d | sed -E "s_^ *\[(.*):(.*)\] ([^\t]*)\t?.*_[\1:\2  \3]_")"
