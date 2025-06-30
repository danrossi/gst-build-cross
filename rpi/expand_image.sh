#!/bin/sh
GIB_IN_BYTES="1073741824"

image_path="2024-07-04-raspios-bookworm-arm64-lite.img"
qemu-img info $image_path
image_size_in_bytes=$(qemu-img info --output json $image_path | grep "virtual-size" | awk '{print $2}' | sed 's/,//')
if [ "$(($image_size_in_bytes % ($GIB_IN_BYTES * 2)))" != "0" ]; then
  new_size_in_gib=$((($image_size_in_bytes / ($GIB_IN_BYTES * 2) + 1) * 2))
  echo "Rounding image size up to ${new_size_in_gib}GiB so it's a multiple of 2GiB..."
  qemu-img resize $image_path "${new_size_in_gib}G"
fi