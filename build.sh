#!/bin/bash
set -e

# ====================================================
# SCRIPT BUILD KERNEL CLEAN / OUT-OF-TREE (Mint/Ubuntu)
# Target: Intel Core i5-2500 (Sandy Bridge)
# ====================================================

if [ ! -f "Kbuild" ]; then
    echo "Error: Run this script from the root of the kernel source folder!"
    exit 1
fi

OUT_DIR="out"
mkdir -p "$OUT_DIR"

echo "========== [1/5] Preparing Config =========="

if [ ! -f "$OUT_DIR/.config" ]; then
    if [ -f "i5_2500.config" ]; then
        echo "Using the my_i5_2500.config file from root..."
        cp i5_2500.config "$OUT_DIR/.config"
    else
        echo "Fetching active config from /boot..."
        cp /boot/config-$(uname -r) "$OUT_DIR/.config"
    fi
fi

echo "========== [2/5] Cleaning Canonical Keys & Module Signing =========="

scripts/config --file "$OUT_DIR/.config" --set-str CONFIG_SYSTEM_TRUSTED_KEYS ""
scripts/config --file "$OUT_DIR/.config" --set-str CONFIG_SYSTEM_REVOCATION_KEYS ""
scripts/config --file "$OUT_DIR/.config" --disable CONFIG_MODULE_SIG_FORCE
scripts/config --file "$OUT_DIR/.config" --set-str CONFIG_EXTRA_FIRMWARE ""

echo "========== [3/5] Sync Config with Out-of-Tree =========="
make O="$OUT_DIR" olddefconfig

echo "========== [4/5] Starting the Compilation Process (Out-of-Tree) =========="

make O="$OUT_DIR" CC="ccache gcc" -j4 bindeb-pkg

echo "========== [5/5] Finished! =========="
echo "The resulting .deb and kiner files are in a folder one level above out/"
