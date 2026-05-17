# COLA Fortran

[![CI](https://github.com/ZakayZ/COLA_Fortran/actions/workflows/ci.yaml/badge.svg)](https://github.com/ZakayZ/COLA_Fortran/actions/workflows/ci.yaml)

Fortran bindings and CMake tooling for [COLA](https://github.com/Spectator-matter-group-INR-RAS/COLA) pipeline modules.

## Installation

Install COLA first, then point CMake at the install prefix and build:

```bash
export CMAKE_PREFIX_PATH=/path/to/cola/install:${CMAKE_PREFIX_PATH}
cmake --preset release
cmake --build --preset release
cmake --install build/release
```

## Example

See the [`example/`](example/) directory for a minimal Fortran module and runner.
