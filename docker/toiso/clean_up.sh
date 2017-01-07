#!/bin/bash
set -e

echo "command > clean up"

source "`dirname \"$0\"`/configuration.sh"

apt-get clean

rm -rf /tmp/*
rm -rf "$filesystem_location/filesystem."*
