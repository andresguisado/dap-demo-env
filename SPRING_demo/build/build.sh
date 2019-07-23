#!/bin/bash
#
#
set -e

readonly IMAGE_NAME="petstore-app"
readonly IMAGE_TAG="$(cat VERSION)"

docker build \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  .

docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest
