#!/bin/bash

if [ -z "$1" ]
then
      echo "please inform repo/imagename/tag"
      echo "ex: ./push.sh leandrovo digitalbank-backend-java 1.0
      exit 1
fi

docker push $1/$2:$3
