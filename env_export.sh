#!/bin/sh

while IFS='' read -r line || [[ -n "$line" ]]; do
    export $line
    echo $line
done < "$1"
