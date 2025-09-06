#!/usr/bin/env bash
options=$(cat ~/.config/eww/options)

terms=$(echo $options | jq --arg term "$1" 'if $term != "" then map(select(.name | test($term; "i"))) | sort_by(.name | length) else [] end')
echo $terms

#result=$(echo $result | jq '.[0] | .exec')
#result="${result#\"}"
#result="${result%\"}"
#recho $result > options
