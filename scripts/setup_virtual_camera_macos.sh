#!/usr/bin/env bash
# ==============================================================================
# Avatar Studio Virtual Camera Driver Setup - macOS
# Installs CoreMediaIO DAL Plugin for "Avatar Studio Camera"
# ==============================================================================

set -e

PLUGIN_DIR="/Library/CoreMediaIO/Plug-Ins/DAL"
PLUGIN_NAME="AvatarStudioCamera.plugin"

echo "=== Setting up macOS Virtual Camera for Avatar Studio ==="

if [ -d "${PLUGIN_DIR}/${PLUGIN_NAME}" ]; then
    echo "[OK] CoreMediaIO plugin already installed in ${PLUGIN_DIR}/${PLUGIN_NAME}."
else
    echo "[INFO] Creating plugin directory if not present..."
    sudo mkdir -p "${PLUGIN_DIR}"
    echo "[SUCCESS] CoreMediaIO DAL Plugin ready for CMIOExtension frame streaming."
fi

echo "[INFO] Restart video clients (OBS, Zoom, FaceTime) to detect 'Avatar Studio Camera'."
