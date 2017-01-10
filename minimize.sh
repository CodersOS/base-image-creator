#!/bin/bash

set -e

image="$1"

if [ -z "$image" ]
then
  echo "# The first argument should be the docker image."
  exit 1
fi

cidfile="/tmp/minimize.sh.cidfile`date '+%N'`"
docker run --cidfile="$cidfile" "$image" /toiso/minimize.sh
minimal_image="docker commit `cat \"$cidfile\"`"
minimal_tag="$image-minimal"
docker tag "$minimal_image" "$minimal_tag"
echo "# Tags for the minimal version are:"
echo "# - $minimal_image"
echo "# - $minimal_tag"
