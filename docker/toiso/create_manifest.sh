#!/bin/bash
set -e

source "`dirname \"$0\"`/configuration.sh"

echo "command > create manifest"

dpkg-query -W --showformat='${Package} ${Version}\n' > "$filesystem_location/filesystem.manifest"
cp -v "$filesystem_location/filesystem.manifest" "$filesystem_location/filesystem.manifest-desktop"

for i in $REMOVE
do
  sed -i "/${i}/d" "$filesystem_location/filesystem.manifest-desktop"
done
