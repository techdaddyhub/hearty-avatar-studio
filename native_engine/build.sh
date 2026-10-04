#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Building Avatar Studio Native Bridge Shared Library ==="

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    clang -O3 -fPIC -shared -Iinclude \
        src/avatar_vcam_linux.c \
        src/avatar_telemetry.c \
        -o libavatar_native_bridge.so
    echo "[OK] Built libavatar_native_bridge.so for Linux"

    mkdir -p "$SCRIPT_DIR/../Orange_flutter/Orange/build_native"
    cp libavatar_native_bridge.so "$SCRIPT_DIR/../Orange_flutter/Orange/build_native/"
    echo "[OK] Installed to Orange_flutter/Orange/build_native/libavatar_native_bridge.so"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    clang -O3 -fPIC -shared -Iinclude -framework Foundation -framework CoreMedia -framework CoreVideo \
        src/avatar_vcam_macos.m \
        src/avatar_telemetry.c \
        -o libavatar_native_bridge.dylib
    echo "[OK] Built libavatar_native_bridge.dylib for macOS"
else
    echo "For Windows, compile with MSVC or Clang-CL into avatar_native_bridge.dll"
fi
