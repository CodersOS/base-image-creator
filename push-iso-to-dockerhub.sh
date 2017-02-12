#!/bin/bash
set -e

cd "`dirname \"$0\"`"

date_of_start=$(date +"%s")
function duration() {
  local now=$(date +"%s")
  local _duration=$(($now-$date_of_start))
  echo "# Duration: $(($_duration / 60))m $(($_duration % 60))s"
}


image="$1"

dockerfile_filesystem="docker/filesystem"
cache="docker/filesystem.origin"
if [ -f "$cache" ]
then
  target="`cat \"$cache\"`"
  echo "# Found previous file system in $cache. Moving it to \"$target\"."
  rm "$cache"
  sudo mv "$dockerfile_filesystem" "$target"
fi

if [ -z "$image" ]
then
  echo "# Please pass the image as the first argument!"
  exit 1
fi

echo "# Installing tools ... "
install=""
if ! [ -e "/usr/bin/realpath" ]
then
  install="$install realpath"
fi
if ! [ -e "/usr/bin/unsquashfs" ]
then
  install="$install squashfs-tools"
fi
if [ -n "$install" ]
then
  sudo apt-get -y -qq install $install
fi

echo "# Reading ISO contents ... "
duration
image_name="`basename \"$image\"`"
mount_point="$image_name-mount"
filesystem="$image_name-filesystem"

echo "# Mounting iso to $mount_point"
duration
mkdir -p "$mount_point"
sudo umount "$mount_point" 2> /tmp/mount-error || true
if ! sudo mount -o loop "$image" "$mount_point"
then
  cat /tmp/mount-error
  exit 1
fi

echo "# Unpacking the file system to $filesystem"
duration
relative_filesystem_squashfs="`( cd \"$mount_point\" && find -name filesystem.squashfs )`"
if [ -z "$relative_filesystem_squashfs" ]
then
  echo "# ERROR: did not find filesystem.squashfs in $mount_point"
  duration
  exit 1
fi
if [ -z "`ls \"$filesystem\" 2>/dev/null`" ]
then
  filesystem_squashfs="$mount_point/$relative_filesystem_squashfs"
  echo "# extracting filesystem from $filesystem_squashfs"
  mkdir -p "$filesystem"
  sudo unsquashfs -f -d "$filesystem" "$filesystem_squashfs"
else
  echo "# This was done before, doing nothing."
fi

echo "# Copying iso to docker folder"
duration
dockerfile_iso_path="docker/iso"

sudo rm -rf "$dockerfile_iso_path"
mkdir -p "$dockerfile_iso_path"
echo "# Removing filesytem.squashfs since it is not needed in container."
duration
for source in `( cd "$mount_point" ; find . -not -name filesystem.squashfs )`
do
  if [ -d "$mount_point/$source" ]
  then
    mkdir -p "$dockerfile_iso_path/$source"
  else
    cp -t "$dockerfile_iso_path/`dirname \"$source\"`" "$mount_point/$source"
  fi
done

echo "# Moving file system to docker folder"
duration
sudo rm -rf "$dockerfile_filesystem"
sudo mv "$filesystem" "$dockerfile_filesystem"
echo -n "$filesystem" > "$cache"

echo "# Setting relative filesystem.squashfs path."
echo -n "`dirname \"$relative_filesystem_squashfs\"`" > "docker/toiso/filesystem.squashfs.directory"

echo "# Creating docker image name accoring to"
echo "#   https://github.com/docker/docker/blob/master/image/spec/v1.md"
dockerhub_organization="codersosimages"
docker_image_name="`echo \"${image_name%.*}\" | tr -c '[:alnum:]._-' _ | head -c -1`"
docker_image_name="$dockerhub_organization/$docker_image_name"
echo "# labels: $docker_image_name and $full_docker_image_name"
duration

sudo docker rmi -f "$docker_image_name" 2>>/dev/null || true
sudo docker build -t "$docker_image_name" docker

echo "# Pushing the image to dockerhub"
duration
docker push "$docker_image_name"

