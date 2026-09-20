#!/bin/bash

USER_NAME=$(whoami)
CURRENT_DIR=$(pwd)
CURRENT_DATE=$(date)
HOST_NAME=$(hostname)

echo "===== SRE SYSTEM CHECK ====="
echo
echo "Hostname: $HOST_NAME"
echo "User: $USER_NAME"
echo "Directory: $CURRENT_DIR"
echo "Date: $CURRENT_DATE"
echo
echo "===== DISK USAGE ====="
df -h /
echo
echo "===== MEMORY USAGE ====="
free -h
echo
echo "===== DISK HEALTH CHECK ====="

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

echo "Root filesystem usage: $DISK_USAGE%"

if [ "$DISK_USAGE" -ge 80 ]; then
	echo "WARNING: Disk usage is too high"
	exit 1
else
	echo "OK: Disk usage is healthy"
	exit 0
fi
