#!/usr/bin/env python3
"""
Compare COLA-wrapped UrQMD output to pure UrQMD output.
Both use same seed (12345) and params: Au+Au, b=5fm, E=100 AGeV, 200 fm/c.
Compares particle count and (t,x,y,z,E,px,py,pz) per particle.
"""
import sys
import os

def parse_cola(path):
    """Parse cola_particles.txt: first line = count, then t x y z E px py pz pdg per particle."""
    particles = []
    with open(path) as f:
        n = int(f.readline())
        for _ in range(n):
            parts = f.readline().split()
            if len(parts) < 8:
                continue
            t, x, y, z = float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])
            e, px, py, pz = float(parts[4]), float(parts[5]), float(parts[6]), float(parts[7])
            particles.append((t, x, y, z, e, px, py, pz))
    return particles

def parse_file14(path):
    """Parse UrQMD file14: npart,ttime; stats line; then r0 rx ry rz p0 px py pz m ityp iso3 ... per particle."""
    particles = []
    with open(path) as f:
        line1 = f.readline().split()
        if not line1:
            return particles
        npart = int(line1[0])
        f.readline()  # stats line
        for _ in range(npart):
            parts = f.readline().split()
            if len(parts) < 9:
                continue
            r0, rx, ry, rz = float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])
            p0, px, py, pz = float(parts[4]), float(parts[5]), float(parts[6]), float(parts[7])
            particles.append((r0, rx, ry, rz, p0, px, py, pz))
    return particles

def compare(cola_path, urqmd_path, tol=1e-4):
    cola = parse_cola(cola_path)
    urqmd = parse_file14(urqmd_path)

    print("=" * 60)
    print("COLA vs pure UrQMD comparison (seed=12345, Au+Au, b=5, E=100)")
    print("=" * 60)
    print(f"COLA particle count:   {len(cola)}")
    print(f"Pure UrQMD count:      {len(urqmd)}")
    print()

    if len(cola) != len(urqmd):
        print("MISMATCH: particle counts differ")
        return False

    # Sort by (t,x,y,z,px,py,pz) for matching
    def key(p):
        return (p[0], p[1], p[2], p[3], p[5], p[6], p[7])

    cola_sorted = sorted(cola, key=key)
    urqmd_sorted = sorted(urqmd, key=key)

    n_diff = 0
    max_diff = 0.0
    for i, (c, u) in enumerate(zip(cola_sorted, urqmd_sorted)):
        for j, (a, b) in enumerate(zip(c, u)):
            d = abs(a - b)
            if d > tol:
                n_diff += 1
                max_diff = max(max_diff, d)
                if n_diff <= 5:
                    names = "t x y z E px py pz".split()
                    print(f"  Particle {i} {names[j]}: {a:.6e} vs {b:.6e} (diff {d:.2e})")
                break

    if n_diff == 0:
        print("OK: outputs match within tolerance")
        return True
    else:
        print(f"MISMATCH: {n_diff} particles differ (max diff {max_diff:.2e})")
        return False

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # All paths relative to urqmd-4/ (run from urqmd-4/)
    cola_path = os.path.join(script_dir, "cola_particles.txt")
    # Original UrQMD output (file14 format) - saved from another machine
    urqmd_candidates = [
        os.path.join(script_dir, "original_urqmd_file14"),
        os.path.join(script_dir, "reference", "file14"),
        os.path.join(script_dir, "urqmd_pure_output", "file14"),
    ]
    urqmd_path = None
    for p in urqmd_candidates:
        if os.path.exists(p):
            urqmd_path = p
            break

    if not os.path.exists(cola_path):
        print(f"Error: {cola_path} not found. Run RunCompare first (from urqmd-4/).")
        sys.exit(1)
    if urqmd_path is None:
        print("Error: Original UrQMD output not found. Put file14 in one of:")
        for p in urqmd_candidates:
            print(f"  {p}")
        sys.exit(1)

    ok = compare(cola_path, urqmd_path)
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
