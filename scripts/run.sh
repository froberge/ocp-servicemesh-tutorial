#!/bin/bash

url=$1
if [ -z "$url" ]
then
    echo "No url provided - Need an url to curl"
    exit 1
fi

while true
do curl $url
sleep .5
done