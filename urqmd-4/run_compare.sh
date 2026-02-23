#!/bin/bash
# Run COLA-wrapped UrQMD and compare to saved original UrQMD output.
# Run from urqmd-4/ directory. Requires: cmake --build build
# Usage: ./run_compare.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Run COLA RunCompare -> cola_particles.txt (in urqmd-4/)
# echo "Running COLA RunCompare..."
./build/RunCompare
echo "  -> cola_particles.txt"

# 2. Compare with saved original UrQMD output (file14 format)
python3 "$SCRIPT_DIR/compare_outputs.py"
