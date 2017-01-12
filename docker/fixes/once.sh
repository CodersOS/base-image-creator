#!/bin/bash

cd "`dirname \"$0\"`"

for fix in once/*
do
  echo "-----------------------------------------------------------"
  echo " Executing $fix"
  "$fix"
  error="$?"
  echo
  if [ "$error" == "0" ]
  then
    echo "$fix succeeded."
  else
    echo "$fix failed with code $error."
  fi
done

exit 0
