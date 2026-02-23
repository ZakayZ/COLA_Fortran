#!/bin/bash
# Run Runner from urqmd-4/ directory (so urqmd_compare_input and tables.dat are found).
# Usage: ./run_runner.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
./build/Runner
