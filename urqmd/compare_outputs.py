#!/usr/bin/env python3
"""Compare COLA EventData (cola_particles.txt) to pure UrQMD file14 output."""
import sys
import os


def parse_cola(path):
    """Parse cola_particles.txt: count line, then t x y z E px py pz pdg per particle.
    Skips header/banner lines until the particle count is found."""
    particles = []
    with open(path) as f:
        for line in f:
            s = line.strip()
            if s and s.isdigit():
                n = int(s)
                break
        else:
            raise ValueError(f"No particle count line found in {path} (expected digit-only first data line)")
        for _ in range(n):
            parts = f.readline().split()
            if len(parts) < 8:
                continue
            try:
                t, x, y, z = float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])
                e, px, py, pz = float(parts[4]), float(parts[5]), float(parts[6]), float(parts[7])
                particles.append((t, x, y, z, e, px, py, pz))
            except (ValueError, IndexError):
                continue
    return particles


def parse_file14(path):
    """Parse the last event block from UrQMD file14 (all npart particles)."""
    with open(path) as f:
        lines = f.readlines()

    last_particles = []
    i = 0
    while i < len(lines):
        parts = lines[i].split()
        if len(parts) >= 2:
            try:
                npart = int(parts[0])
                int(parts[1])  # ttime
            except ValueError:
                i += 1
                continue

            # Expect collision-stats line after header
            if i + 1 >= len(lines):
                break
            stats = lines[i + 1].split()
            if len(stats) < 8:
                i += 1
                continue
            try:
                [int(x) for x in stats[:8]]
            except ValueError:
                i += 1
                continue

            block = []
            j = i + 2
            ok_block = True
            for _ in range(npart):
                if j >= len(lines):
                    ok_block = False
                    break
                toks = lines[j].split()
                if len(toks) < 9:
                    ok_block = False
                    break
                try:
                    r0, rx, ry, rz = float(toks[0]), float(toks[1]), float(toks[2]), float(toks[3])
                    p0, px, py, pz = float(toks[4]), float(toks[5]), float(toks[6]), float(toks[7])
                except ValueError:
                    ok_block = False
                    break
                block.append((r0, rx, ry, rz, p0, px, py, pz))
                j += 1

            if ok_block:
                last_particles = block
                i = j
                continue
        i += 1

    return last_particles


def _compare_particles(a, b, cola_path, ref_path, ref_name, tol=1e-4):
    print("=" * 60)
    print("COLA vs pure UrQMD comparison")
    print("=" * 60)
    print(f"COLA ({cola_path}): {len(a)} particles")
    print(f"Reference ({ref_name}, {ref_path}): {len(b)} particles")
    print()

    if len(a) != len(b):
        print("MISMATCH: particle counts differ")
        return False

    def key(p):
        return (p[0], p[1], p[2], p[3], p[5], p[6], p[7])

    a_sorted = sorted(a, key=key)
    b_sorted = sorted(b, key=key)

    n_diff = 0
    max_diff = 0.0
    for i, (pa, pb) in enumerate(zip(a_sorted, b_sorted)):
        for j, (va, vb) in enumerate(zip(pa, pb)):
            d = abs(va - vb)
            if d > tol:
                n_diff += 1
                max_diff = max(max_diff, d)
                if n_diff <= 5:
                    names = "t x y z E px py pz".split()
                    print(f"  Particle {i} {names[j]}: {va:.6e} vs {vb:.6e} (diff {d:.2e})")
                break

    if n_diff == 0:
        print("OK: outputs match within tolerance")
        return True
    else:
        print(f"MISMATCH: {n_diff} particles differ (max diff {max_diff:.2e})")
        return False


def compare(cola_path, ref_path, tol=1e-4):
    """Compare cola_particles.txt to UrQMD file14 reference."""
    a = parse_cola(cola_path)
    b = parse_file14(ref_path)
    ref_name = "file14"
    return _compare_particles(a, b, cola_path, ref_path, ref_name, tol)


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    default_cola = os.path.join(script_dir, "cola_particles.txt")
    default_ref = os.path.join(script_dir, "build", "urqmd_pure_output", "file14")

    if len(sys.argv) >= 3:
        cola_path, ref_path = sys.argv[1], sys.argv[2]
    elif len(sys.argv) == 2:
        cola_path = sys.argv[1]
        ref_path = default_ref
    else:
        cola_path = default_cola
        ref_path = default_ref

    if not os.path.exists(cola_path):
        print(f"Error: {cola_path} not found. Run Runner first (from urqmd-4/).")
        sys.exit(1)
    if not os.path.exists(ref_path):
        print(f"Error: {ref_path} not found. Run ./run_urqmd_pure.sh to generate file14.")
        sys.exit(1)

    ok = compare(cola_path, ref_path)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
