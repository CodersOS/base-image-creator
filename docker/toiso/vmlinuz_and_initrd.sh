#!/bin/bash
set -e

cd "`dirname \"$0\"`"
source "configuration.sh"

echo "command > creating the vmlinuz and initrd files"

for file in /boot/vmlinuz-**-generic
do
  if [ -f "$file" ]
  then
    cp "$file" "$filesystem_location/vmlinuz.efi"
  fi
done

for file in /boot/initrd.img-**-generic
do
  if [ -f "$file" ]
  then
    cp "$file" "$filesystem_location/initrd.lz"
  fi
done
