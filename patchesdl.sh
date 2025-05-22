#!/usr/bin/env bash
set -e

mkdir -p kernel_patches

i=1
while read -r url; do
  filename=$(basename "$url")
  printf -v prefix "%03d" "$i"
  curl -L "$url" -o "kernel_patches/${prefix}_$filename"
  ((i++))
done < patches.txt

cd linux-6.15-rc7

for patch in ../kernel_patches/*.patch; do
  echo "Applying $patch"
  patch -p1 < "$patch" || { echo "Failed to apply $patch"; exit 1; }
done

echo "All patches applied successfully."
