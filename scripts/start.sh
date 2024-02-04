#!/bin/bash
# Ubuntu ISO setup script
# Copyright 2024 Heusala Group Ltd <info@hg.fi>
#

SERVER_IMAGE_TYPE='qcow2'
SERVER_IMAGE_FILE="ubuntu-server"
WORKING_DIR='.'
IMAGES_DIR='images'

qemu-system-x86_64 \
    -cpu max \
    -no-reboot \
    -m 4096 \
    -net user,hostfwd=tcp::10022-:22 \
    -net nic \
    -drive "file=${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE},format=${SERVER_IMAGE_TYPE},if=virtio" &
