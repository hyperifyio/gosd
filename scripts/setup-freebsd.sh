#!/bin/bash
# FreeBSD VM setup script
# Copyright 2024 Heusala Group Ltd <info@hg.fi>
#

DOWNLOADS_DIR="downloads"
EXTRACTOR=""
EXTRACTOR_OPTS=""
FREEBSD_VM_URL="https://download.freebsd.org/releases/VM-IMAGES/14.0-RELEASE/amd64/Latest/FreeBSD-14.0-RELEASE-amd64-zfs.qcow2.xz"
FREEBSD_VM_ARCHIVE="$(basename "${FREEBSD_VM_URL}")"
FREEBSD_VM_IMAGE="freebsd-server.qcow2"
IMAGES_DIR="images"
WORKING_DIR="."

# Check QEMU
if which qemu-system-x86_64 > /dev/null 2>/dev/null; then
    :
else
    if [ "$(uname)" == "Darwin" ]; then
        echo
        echo "No QEMU installed. You can install it using:"
        echo
        echo "  brew install qemu"
        echo
        exit 1
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo
        echo "No QEMU installed. You can install it using:"
        echo
        echo "  sudo apt-get install qemu-system-x86"
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
        echo "No wget installed. You can install it using:" >&2
        echo >&2
        echo "  brew install wget" >&2
        echo >&2
        exit 1
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo >&2
        echo "No wget installed. You can install it using:" >&2
        echo >&2
        echo "  sudo apt-get install wget" >&2
        echo >&2
        exit 1
    fi
fi

# Check 7z/xz
if which 7z > /dev/null 2>/dev/null; then
    EXTRACTOR="7z"
    EXTRACTOR_OPTS=("e" "-o${WORKING_DIR}/${DOWNLOADS_DIR}")
    :
else
    if which xz > /dev/null 2>/dev/null; then
        EXTRACTOR="xz"
        EXTRACTOR_OPTS=("--decompress" "--keep")
        :
    else
        if [ "$(uname)" == "Darwin" ]; then
            echo >&2
            echo "No 7z or xz installed. You can install either by using:" >&2
            echo >&2
            echo "  brew install sevenzip" >&2
            echo "  brew install xz" >&2
            echo >&2
            exit 1
        elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
            echo >&2
            echo "No 7z or xz installed. You can install either by using:" >&2
            echo >&2
            echo "  sudo apt-get install p7zip-full" >&2
            echo "  sudo apt-get install xz-utils" >&2
            echo >&2
            exit 1
        fi
    fi
fi

set -x
set -e

if test -f "${WORKING_DIR}/${IMAGES_DIR}/${FREEBSD_VM_IMAGE}"; then
    echo >&2
    echo "${WORKING_DIR}/${IMAGES_DIR}/${FREEBSD_VM_IMAGE} exists already." >&2
    echo "Please remove, or rename it before running this script to replace it." >&2
    echo >&2
else
    # Download FreeBSD server VM archive
    if test -f "${WORKING_DIR}/${DOWNLOADS_DIR}/${FREEBSD_VM_ARCHIVE}"; then
        echo "Using previous VM archive: ${WORKING_DIR}/${DOWNLOADS_DIR}/${FREEBSD_VM_ARCHIVE}"
    else
        echo "Downloading VM archive as: ${WORKING_DIR}/${DOWNLOADS_DIR}/${FREEBSD_VM_ARCHIVE}"
        wget -O "${WORKING_DIR}/${DOWNLOADS_DIR}/${FREEBSD_VM_ARCHIVE}" "${FREEBSD_VM_URL}"
    fi

    echo "Verifying the VM image..."

    if (cd ${DOWNLOADS_DIR} && shasum --ignore-missing -a 256 -c "./freebsd-CHECKSUM.SHA256") 2>&1; then
        :
    else
        echo >&2
        echo "ERROR: SHA256 verification failed for: ${DOWNLOADS_DIR}/freebsd-CHECKSUM.SHA256" >&2
        echo >&2
        exit 4
    fi

    # Uncompress the VM image
    echo "Uncompressing the VM image..."

    "${EXTRACTOR}" "${EXTRACTOR_OPTS[@]}" \
        "${WORKING_DIR}/${DOWNLOADS_DIR}/${FREEBSD_VM_ARCHIVE}"

    mv "${WORKING_DIR}/${DOWNLOADS_DIR}/${FREEBSD_VM_ARCHIVE/.xz/}" \
        "${WORKING_DIR}/${IMAGES_DIR}/${FREEBSD_VM_IMAGE}"
fi

echo "SETUP OK"
