#!/bin/bash

export $(grep -v '^#' /root/minecraft/.env | xargs)

latest=$(rclone lsf ${RCLONE_REMOTE}:${SERVER_NAME} --include "world-*" --files-only --order-by 'modtime' -v | tail -n 1)

if [ -z "$latest" ]; then
    echo "No backup found"
    exit 1
else
    echo "Backup found: $latest"
    rclone copy ${RCLONE_REMOTE}:${SERVER_NAME}/${latest} /root/minecraft/mc-backups
    exit 0
fi