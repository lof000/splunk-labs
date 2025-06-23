#!/bin/bash

if [ -z "$1" ]
then
      echo "please inform repo/imagename/tag"
      echo "ex: ./build.sh leandrovo/digitalbank-backend-java 3.0
      exit 1
fi

docker buildx build --platform linux/amd64,linux/arm64 -t $1/$2:$3 -f Dockerfile .

