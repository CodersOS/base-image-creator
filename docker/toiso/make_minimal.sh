#!/bin/bash
set -e

cd "`dirname \"$0\"`"
source "configuration.sh"

minimal_packages="`cat installed-minimal-packages.txt | grep -vE '^\s*#|^\s*$'`"

for package in $minimal_packages
do
  echo -n "Installing package $package ... "
  if apt-get -y -q --purge install "$package"
  then
    echo "ok"
  else
    echo "fail"
  fi
done

for package in `apt list --installed | grep -oE '^[^/]+'`
do
  if apt-cache rdepends --recurse "$package" | grep -oE '\S+' | grep -qxF "$minimal_packages"
  then
    dependencies="`apt-cache rdepends --recurse \"$package\" | grep -oE '\S+' | grep -m 5 -oxF \"$minimal_packages\" | sort | uniq`"
    echo "Not removing because of dependencies: $package ->" $dependencies
  else
    echo -n "Removing package $package ... "
    if apt-get -y -qq --purge remove "$package"
    then
      echo "ok"
    else
      echo "fail"
    fi
  fi
done
