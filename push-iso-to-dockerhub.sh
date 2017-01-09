#!/bin/bash
set -e

cd "`dirname \"$0\"`"

image="$1"

dockerfile_filesystem="docker/filesystem"
cache="docker/filesystem.origin"
if [ -f "$cache" ]
then
  target="`cat \"$cache\"`"
  echo "# Found previous file system in $cache. Mooving it to \"$target\"."
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
image_name="`basename \"$image\"`"
mount_point="$image_name-mount"
filesystem="$image_name-filesystem"
echo "# mounting iso to $mount_point"
mkdir -p "$mount_point"
sudo umount "$mount_point" 2>>/dev/null || true
sudo mount -o loop "$image" "$mount_point"

echo "# Unpacking the file system to $filesystem"
relative_filesystem_squashfs="`( cd \"$mount_point\" && find -name filesystem.squashfs )`"
if [ -z "$relative_filesystem_squashfs" ]
then
  echo "# ERROR: did not find filesystem.squashfs in $mount_point"
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
dockerfile_iso_path="docker/iso"

mkdir -p "$dockerfile_iso_path"
cp -r -t "$dockerfile_iso_path" "$mount_point"
echo "# Removing filesytem.squashfs since it is not needed in container."
rm "$docker_iso_path/$relative_filesystem_squashfs"

echo "# Moving file system to docker folder"
sudo rm -rf "$dockerfile_filesystem"
sudo mv "$filesystem" "$dockerfile_filesystem"
echo -n "$filesystem" > "$cache"

echo "Setting relative filesystem.squashfs path."
echo -n "`dirname \"$relative_filesystem_squashfs\"`" > "docker/toiso/filesystem.squashfs.directory"

echo "# Creating docker image name accoring to"
echo "#   https://github.com/docker/docker/blob/master/image/spec/v1.md"
dockerhub_organization="codersosimages"
docker_image_name="`echo \"${image_name%.*}\" | tr -c '[:alnum:]._-' _ | head -c -1`"
full_docker_image_name="$dockerhub_organization/$docker_image_name"
echo "# labels: $docker_image_name and $full_docker_image_name"

sudo docker rmi -f "$full_docker_image_name" 2>>/dev/null || true
sudo docker rmi -f "$docker_image_name" 2>>/dev/null || true
sudo docker build -t "$full_docker_image_name" -t "$docker_image_name" docker

echo "# Pushing the image to dockerhub"
docker push "$full_docker_image_name"
