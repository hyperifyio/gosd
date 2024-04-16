#!/bin/bash
# Ubuntu ISO setup script
# Copyright 2024 Heusala Group Ltd <info@hg.fi>
#

UBUNTU_ISO_URL='https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso'
UBUNTU_SEED_ISO_FILE_NAME='ubuntu-seed.iso'
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
        echo '  sudo apt-get install qemu-system-x86'
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

# Check expect
if which expect > /dev/null 2>/dev/null; then
    :
else
    if [ "$(uname)" == "Darwin" ]; then
        echo
        echo 'No expect installed. You can install it using:'
        echo
        echo '  brew install expect'
        echo
        exit 1
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo
        echo 'No expect installed. You can install it using:'
        echo
        echo '  sudo apt-get install expect'
        echo
        exit 1
    fi
fi

set -x
set -e

if test -f "${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE}"; then
    echo 'Using previous image'
else

    # Check if VM image exists already
    if test -f "${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE}"; then
        echo "ERROR: Server image exists already: ${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE}"
        exit 2
    fi

    # Download Ubuntu Server ISO
    UBUNTU_ISO_FILE_NAME="$(basename "${UBUNTU_ISO_URL}")"
    if test -f "${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}"; then
        echo "Using previous ISO image: ${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}"
    else
        echo "Downloading ISO image as: ${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}"
        wget -O "${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}" "${UBUNTU_ISO_URL}"
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

    echo 'Verifying ISO images...'
    if gpg --keyid-format long --verify "${DOWNLOADS_DIR}/SHA256SUMS.gpg" "${DOWNLOADS_DIR}/SHA256SUMS"; then
        echo 'ISO images OK'
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

    # Create a new VM disk image
    echo 'Creating image... '
    qemu-img create \
        -f "${SERVER_IMAGE_TYPE}" \
        "${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE}" \
        "${SERVER_IMAGE_SIZE}"

    # Run QEMU with expect using a here document
    echo 'Installing system... '
    expect << END_EXPECT

    match_max 30000

    set down   "\016"
    set end    "\005"
    set left   "\002"
    set home   "\001"
    set ctrl_x "\030"
    set ctrl_l "\014"

    proc wait_for_pattern {expected_pattern timeout max_loops timeout_after} {
        global spawn_id
        global ctrl_l
        set timeout \$timeout
        set loop_counter 0
        while {\$loop_counter < \$max_loops} {
            expect {
                \$expected_pattern {
                    break
                }
                timeout {
                    send \$ctrl_l
                    incr loop_counter
                }
                eof {
                    send_user "\nEOF detected while waiting pattern \$expected_pattern\n"
                    exit 2
                }
            }
        }
        if {\$loop_counter >= \$max_loops} {
            send_user "Maximum number of retries reached while waiting pattern \$expected_pattern. Exiting.\n"
            exit 1
        }
        set timeout \$timeout_after
    }

    set timeout 20

    spawn qemu-system-x86_64 \
        -cpu max \
        -nographic \
        -no-reboot \
        -m 4096 \
        -boot d \
        -net user,hostfwd=tcp::10022-:22 \
        -net nic \
        -cdrom "${WORKING_DIR}/${DOWNLOADS_DIR}/${UBUNTU_ISO_FILE_NAME}" \
        -drive "file=${WORKING_DIR}/${IMAGES_DIR}/${UBUNTU_SEED_ISO_FILE_NAME},format=raw" \
        -drive "file=${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE},format=${SERVER_IMAGE_TYPE},if=virtio"

    match_max -i \$spawn_id 30000

    sleep 1

    wait_for_pattern " to edit the commands" 20 10 60
    sleep 1

    send "e"
    wait_for_pattern "/casper/vmlinuz  ---" 20 10 60
    sleep 1

    send "\$down\$down\$down\$end\$left\$left\$left\$left"
    send "auto\$ctrl_l"
    wait_for_pattern "/casper/vmlinuz auto ---" 20 10 60
    sleep 1

    send "install\$ctrl_l"
    wait_for_pattern "/casper/vmlinuz autoinstall ---" 20 10 60
    sleep 1

    send " text\$ctrl_l"
    wait_for_pattern "/casper/vmlinuz autoinstall text ---" 20 10 60
    sleep 1

    send " console=\$ctrl_l"
    wait_for_pattern "/casper/vmlinuz autoinstall text console= ---" 20 10 60
    sleep 1

    send "ttyS0,115200\$down"
    wait_for_pattern "/casper/vmlinuz autoinstall text console=ttyS0,115200 " 20 10 60
    sleep 1

    send "\$ctrl_x"
    wait_for_pattern "Booting a command list" 600 10 600
    wait_for_pattern "0.000000] Linux version" 600 10 600
    wait_for_pattern "waiting for cloud-init..." 600 10 600
    wait_for_pattern "reboot: Restarting system" 600 10 600

    expect eof
    send_user "Installation ready"
    exit 0

END_EXPECT
fi

cleanup() {
    echo "Shutting down QEMU..."
    # Gracefully shutdown QEMU (e.g., via QEMU monitor or sending kill signal)
    kill $QEMU_PID
}

#echo 'Starting the system'
#qemu-system-x86_64 \
#    -cpu max \
#    -no-reboot \
#    -m 4096 \
#    -net user,hostfwd=tcp::10022-:22 \
#    -net nic \
#    -drive "file=${WORKING_DIR}/${IMAGES_DIR}/${SERVER_IMAGE_FILE}.${SERVER_IMAGE_TYPE},format=${SERVER_IMAGE_TYPE},if=virtio" &
#QEMU_PID=$!
#trap cleanup EXIT

#ansible all -i "localhost:10022," \
#        -m apt -a "name=ansible state=present" \
#        --become --user ubuntu \
#        --extra-vars "ansible_user=ubuntu ansible_password=ubuntu ansible_ssh_pass=ubuntu ansible_become_pass=ubuntu" \
#        -e 'ansible_python_interpreter=/usr/bin/python3'

# Script continues after manual installation
# SSH into the VM and install Ansible
# ...

# Create and transfer SystemD service file
# ...

# Enable and start Ansible service
# ...

echo 'SETUP OK'
