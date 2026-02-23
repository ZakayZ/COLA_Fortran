# URQMD-4 COLA Wrapper

COLA Fortran wrapper for UrQMD 4.0 (hadronic transport model).

## Configuration

Parameters are passed via the C++ `Create()` map. Two modes:

1. **config_path**: Use an existing UrQMD input file directly.
   ```cpp
   filter->Create({{"config_path", "path/to/urqmd_input"}});
   ```

2. **Map-based**: Create a config file from key-value pairs.
   Each map entry is written as `key value`. Use UrQMD input keys (pro, tar, imp, elb, tim, rsd, etc.).
   By default the file is written to the temp dir (TMPDIR/TEMP/TMP or /tmp). Use `generated_config_path` to specify a path.
   ```cpp
   filter->Create({
       {"pro", "197 79"}, {"tar", "197 79"}, {"nev", "1"},
       {"imp", "5."}, {"elb", "100."}, {"tim", "200 200"}, {"rsd", "12345"}
   });
   ```

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

## Comparing outputs

Runner dumps EventData to `cola_particles.txt`. Compare two runs:

```bash
./run_compare.sh
```

This runs Runner → `cola_particles.txt`, then compares with `reference/cola_particles.txt` if present.
To create a reference: run once, copy `cola_particles.txt` to `reference/cola_particles.txt`.
