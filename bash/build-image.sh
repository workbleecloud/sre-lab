#!/bin/bash

set -euo pipefail

GIT_SHA=$(git rev-parse --short HEAD)
IMAGE_NAME="sre-web:$GIT_SHA"

echo "===== SRE Docker Build ====="
echo "Git commit: $GIT_SHA"
echo "Image: $IMAGE_NAME"

docker build -t "$IMAGE_NAME" ./web

echo
echo "Build complete:"
docker images "$IMAGE_NAME"
