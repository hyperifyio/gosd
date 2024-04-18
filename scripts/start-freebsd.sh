#!/bin/bash
# FreeBSD VM start script
# Copyright 2024 Heusala Group Ltd <info@hg.fi>
#

IMAGES_DIR="images"
SERVER_IMAGE_TYPE="qcow2"
SERVER_IMAGE_FILE="freebsd-server"
WORKING_DIR="."

qemu-system-x86_64 \
    -cpu max \
    -no-reboot \
    -m 4096 \
    -net user,hostfwd=tcp::10022-:22 \
    -net nic \
    -drive "file=${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE},format=${SERVER_IMAGE_TYPE},if=virtio" &
