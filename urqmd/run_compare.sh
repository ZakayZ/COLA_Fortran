#!/bin/bash
# Run COLA-wrapped UrQMD and pure UrQMD, then compare outputs.
# Run from urqmd-4/ directory. Requires: cmake --build build
# Usage: ./run_compare.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Run Runner -> cola_particles.txt
./build/Runner > cola_particles.txt
echo "  -> cola_particles.txt"

# 2. Run pure UrQMD -> build/urqmd_pure_output/file14
./run_urqmd_pure.sh
echo "  -> build/urqmd_pure_output/file14"

# 3. Compare COLA vs pure UrQMD
python3 "$SCRIPT_DIR/compare_outputs.py" cola_particles.txt build/urqmd_pure_output/file14
