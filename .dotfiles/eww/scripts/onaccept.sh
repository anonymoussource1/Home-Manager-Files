#!/usr/bin/env bash
dex $(~/.config/eww/scripts/onchange.sh $1 | jq --raw-output '.[0] | .path')
