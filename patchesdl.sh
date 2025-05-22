#!/usr/bin/env bash

mkdir -p kernel_patches

while read -r url; do
  curl -L "$url" -o "kernel_patches/$(basename "$url")"
done < patches.txt

cd linux

for patch in ../kernel_patches/*.patch; do
  patch -p1 < "$patch" || { echo "Failed to apply $patch"; exit 1; }
done
