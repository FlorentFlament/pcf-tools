#!/usr/bin/env sh

for i in $(cat); do
    echo "$i: $(apg -M LCN -n1 -m 24)"
done
