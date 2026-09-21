#!/bin/bash

set -euo pipefail

GIT_SHA=$(git rev-parse --short HEAD)
IMAGE_NAME="sre-web:$GIT_SHA"
CONTAINER_NAME="sre-web"
HOST_PORT="8080"

# Verify that the Docker image exists before attempting deployment
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "ERROR: Docker image $IMAGE_NAME does not exist" >&2
    echo "Run ./bash/build-image.sh first" >&2
    exit 1
fi

# Check whether a container with the deployment name already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Existing container $CONTAINER_NAME found"
    echo "Removing existing container..."

    docker rm -f "$CONTAINER_NAME"
else
    echo "No existing container $CONTAINER_NAME found"
fi

# Display what we're about to deploy
echo "===== SRE Deployment ====="
echo "Git commit: $GIT_SHA"
echo "Image: $IMAGE_NAME"
echo "Container: $CONTAINER_NAME"
echo "Port: $HOST_PORT"

echo
echo "Starting container $CONTAINER_NAME..."

# Start the application container
docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$HOST_PORT:80" \
    "$IMAGE_NAME"

echo "Container started successfully"

# Start application health check
echo
echo "Checking application health..."

MAX_ATTEMPTS=5
RETRY_DELAY=2

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    echo "Health check attempt $attempt of $MAX_ATTEMPTS..."

    if curl -fsS "http://localhost:$HOST_PORT" > /dev/null; then
        echo "Health check passed"
        echo "Deployment completed successfully"
        exit 0
    fi

    echo "Application not ready yet"

    if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
        sleep "$RETRY_DELAY"
    fi
done

echo "ERROR: Health check failed after $MAX_ATTEMPTS attempts" >&2
exit 1
