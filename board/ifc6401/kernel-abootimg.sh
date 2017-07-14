#!/bin/bash

set -e
BOARD_DIR="$(dirname $0)"

abootimg --create "${BINARIES_DIR}/zImage-dtb.img" -k "${BINARIES_DIR}/zImage-dtb" -r "${BOARD_DIR}/NULL.img" -f "board/ifc6401/bootimg.cfg"
