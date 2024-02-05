#!/bin/bash

calcurse -n | sed 1d | awk '{if (length($0) > 20) {print substr($0, 1, 20) "..."} else {print $0}}' | sed -E "s_^ *\[(.*):(.*)\] ([^\t]*)\t?.*_[\1:\2  \3]_"
