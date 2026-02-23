# URQMD-4 COLA Wrapper

COLA Fortran wrapper for UrQMD 4.0 (hadronic transport model).

## Build

```bash
cd urqmd-4
mkdir build && cd build
cmake ..
make
```

## Running (avoiding segfault)

URQMD needs `tables.dat` for decay widths. Generating it at runtime can segfault when called from the library. Pre-generate it:

1. **From urqmd-4.0 directory** (using original Makefile):
   ```bash
   cd urqmd-4.0
   make
   ./maketables
   cp tables.dat ../urqmd-4/build/
   ```

2. **Run Runner** from the build directory:
   ```bash
   cd ../urqmd-4/build
   ./Runner
   ```

Runner looks for `tables.dat` in the current directory.

## Comparing to pure UrQMD

To compare the COLA wrapper output with standalone UrQMD (same seed, same params):

1. **Build pure UrQMD** (from urqmd-4.0). Use **CMake** (Linux & macOS) or Make:
   ```bash
   cd urqmd-4.0
   mkdir -p build && cd build
   cmake ..
   cmake --build .
   cmake --build . --target maketables   # generate tables.dat
   ```
   Or with Make: `make` then `./maketables`

2. **Run the comparison** (runs both and compares):
   ```bash
   cd ../urqmd-4
   chmod +x run_compare.sh run_urqmd_pure.sh compare_outputs.py
   ./run_compare.sh
   ```

   This will:
   - Run `RunCompare` → writes `build/cola_particles.txt` (t, x, y, z, E, px, py, pz, pdg)
   - Run pure UrQMD → writes `build/urqmd_pure_output/file14`
   - Run `compare_outputs.py` → compares particle count and (t,x,y,z,E,px,py,pz) per particle

3. **Same seed**: Both use `seed=12345` (pmap and `rsd 12345` in `urqmd_compare_input`).

4. **Manual steps** (if needed):
   - `./build/RunCompare` – COLA output only
   - `./run_urqmd_pure.sh` – pure UrQMD only
   - `python3 compare_outputs.py` – compare existing outputs
