#!/usr/bin/env bash
# ==============================================================================
# Avatar Studio Virtual Camera Driver Setup - Linux
# Uses v4l2loopback for zero-copy GPU video frame streaming
# ==============================================================================

set -e

DEVICE_NR=10
LABEL="Avatar Studio Camera"

echo "=== Setting up Linux Virtual Camera for Avatar Studio ==="

# Check if v4l2loopback is loaded
if lsmod | grep -q v4l2loopback; then
    echo "[OK] v4l2loopback kernel module is already loaded."
else
    echo "[INFO] Loading v4l2loopback kernel module (exclusive_caps=1 for Chrome/Zoom/Meet compatibility)..."
    sudo modprobe v4l2loopback video_nr=${DEVICE_NR} card_label="${LABEL}" exclusive_caps=1 || {
        echo "[ERROR] Failed to load v4l2loopback. Please install via: sudo apt-get install -y v4l2loopback-dkms v4l2loopback-utils"
        exit 1
    }
fi

if [ -e "/dev/video${DEVICE_NR}" ]; then
    echo "[SUCCESS] Virtual Camera ready at /dev/video${DEVICE_NR} labeled '${LABEL}'"
else
    echo "[WARNING] /dev/video${DEVICE_NR} not found. Check kernel logs via dmesg."
fi
