#!/bin/bash
# Ubuntu ISO setup script
# Copyright 2024 Heusala Group Ltd <info@hg.fi>
#

UBUNTU_ISO_URL='https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso'
SERVER_IMAGE_TYPE='qcow2'
SERVER_IMAGE_FILE="ubuntu-server"
SERVER_IMAGE_SIZE='20G'
WORKING_DIR='.'
DOWNLOADS_DIR='downloads'
IMAGES_DIR='images'
KEYSERVERS=("keyserver.ubuntu.com" "pgp.mit.edu" "ipv4.pool.sks-keyservers.net" "keyserver.pgp.com")
KEYS=("843938DF228D22F7B3742BC0D94AA3F0EFE21092")

# Check QEMU
if which qemu-system-x86_64 > /dev/null 2>/dev/null; then
    :
else
    if [ "$(uname)" == "Darwin" ]; then
        echo
        echo 'No QEMU installed. You can install it using:'
        echo
        echo '  brew install qemu'
        echo
        exit 1
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo
        echo 'No QEMU installed. You can install it using:'
        echo
        echo '  sudo apt-get install qemu'
        echo
        exit 1
    fi
fi

# Check gpg
if which gpg > /dev/null 2>/dev/null; then
    :
else
    if [ "$(uname)" == "Darwin" ]; then
        echo
        echo 'No gpg installed. You can install it using:'
        echo
        echo '  brew install gpg'
        echo
        exit 1
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo
        echo 'No gpg installed. You can install it using:'
        echo
        echo '  sudo apt-get install gpg'
        echo
        exit 1
    fi
fi

# Check wget
if which wget > /dev/null 2>/dev/null; then
    :
else
    if [ "$(uname)" == "Darwin" ]; then
        echo >&2
        echo 'No wget installed. You can install it using:' >&2
        echo >&2
        echo '  brew install wget' >&2
        echo >&2
        exit 1
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo >&2
        echo 'No wget installed. You can install it using:' >&2
        echo >&2
        echo '  sudo apt-get install wget' >&2
        echo >&2
        exit 1
    fi
fi

# Check and download public keys
for KEY in "${KEYS[@]}"; do
    if gpg --list-keys "${KEY}" > /dev/null 2>&1; then
        :
    else
        echo >&2
        echo "ERROR: GPG Public key ${KEY} for Ubuntu ISO not found. You can add it using one of these:" >&2
        echo >&2
        for KEYSERVER in "${KEYSERVERS[@]}"; do
            echo "    gpg --keyid-format long --keyserver hkp://${KEYSERVER} --recv-keys ${KEY}" >&2
            echo >&2
        done
        exit 2
    fi
done

if gpg --keyid-format long --verify "${DOWNLOADS_DIR}/SHA256SUMS.gpg" "${DOWNLOADS_DIR}/SHA256SUMS"; then
    :
else
    echo >&2
    echo "ERROR: GPG verification failed for: ${DOWNLOADS_DIR}/SHA256SUMS" >&2
    echo >&2
    exit 3
fi

if (cd ${DOWNLOADS_DIR} && shasum --ignore-missing -a 256 -c "./SHA256SUMS") 2>&1; then
    :
else
    echo >&2
    echo "ERROR: SHA256 verification failed for: ${DOWNLOADS_DIR}/SHA256SUMS" >&2
    echo >&2
    exit 4
fi

set -x
set -e

UBUNTU_ISO_FILE_NAME="$(basename "${UBUNTU_ISO_URL}")"

# Download Ubuntu Server ISO
if test -f "${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}"; then
    echo "Using previous ISO image: ${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}"
else
    echo "Downloading ISO image as: ${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}"
    wget -O "${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}" "${UBUNTU_ISO_URL}"
fi

# Check if VM image exists already
if test -f "${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE}"; then
    echo "ERROR: Server image exists already: ${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE}"
    exit 2
fi

# Create a new VM disk image
qemu-img create \
    -f "${SERVER_IMAGE_TYPE}" \
    "${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE}" \
    "${SERVER_IMAGE_SIZE}"

# Start the VM and install Ubuntu there
# (This step will require manual intervention to complete the installation)
qemu-system-x86_64 \
    -boot d \
    -cdrom "${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}" \
    -drive "file=${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE},format=${SERVER_IMAGE_TYPE}"

# Script continues after manual installation
# SSH into the VM and install Ansible
# ...

# Create and transfer SystemD service file
# ...

# Enable and start Ansible service
# ...
