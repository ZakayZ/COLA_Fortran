#!/bin/bash
# Run pure UrQMD with same params as COLA lib for comparison.
# Build: cd urqmd-4.0 && (make || mkdir build && cd build && cmake .. && cmake --build .)
# Usage: ./run_urqmd_pure.sh
#
# Note: Unsets DYLD_LIBRARY_PATH so dyld can find libSystem.B.dylib in /usr/lib.
#       If you have DYLD_LIBRARY_PATH=.local/lib (e.g. for COLA), dyld searches
#       there first for ALL libs and fails to find system libs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URQMD_DIR="${SCRIPT_DIR}/urqmd-4.0"
URQMD_BUILD="${URQMD_DIR}/build"
INPUT="${SCRIPT_DIR}/urqmd_compare_input"
OUTDIR="${SCRIPT_DIR}/build/urqmd_pure_output"
mkdir -p "$OUTDIR"

export ftn09="$INPUT"
export ftn13="$OUTDIR/file13"
export ftn14="$OUTDIR/file14"
export ftn15="$OUTDIR/file15"
export ftn16="$OUTDIR/file16"
export ftn19="$OUTDIR/file19"
export ftn20="$OUTDIR/file20"

ARCH=$(uname -m)
EXE=""
if [[ -x "${URQMD_BUILD}/urqmd.${ARCH}" ]]; then
  EXE="${URQMD_BUILD}/urqmd.${ARCH}"
elif [[ -x "${URQMD_BUILD}/urqmd.x86_64" ]]; then
  EXE="${URQMD_BUILD}/urqmd.x86_64"
elif [[ -x "${URQMD_DIR}/urqmd.${ARCH}" ]]; then
  EXE="${URQMD_DIR}/urqmd.${ARCH}"
elif [[ -x "${URQMD_DIR}/urqmd.x86_64" ]]; then
  EXE="${URQMD_DIR}/urqmd.x86_64"
fi

if [[ -z "$EXE" ]]; then
  echo "Error: UrQMD executable not found."
  echo "  CMake: cd $URQMD_DIR && mkdir -p build && cd build && cmake .. && cmake --build ."
  echo "  Make:  cd $URQMD_DIR && make"
  exit 1
fi

cd "$(dirname "$EXE")"
./$(basename "$EXE")
echo "Output in $OUTDIR"
