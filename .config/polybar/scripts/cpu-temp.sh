#!/bin/bash

echo -n "$(sensors | grep "Tctl" | tr -d "+" | awk '{print $2}')"
