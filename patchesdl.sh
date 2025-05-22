#!/usr/bin/env bash

while read -r url; do
  curl -L "$url" -o "patches/$(basename "$url")"
done < patches.txt
