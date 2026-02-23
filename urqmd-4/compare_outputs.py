#!/usr/bin/env python3
"""
Compare COLA EventData (cola_particles.txt) to pure UrQMD output (file16).
COLA format: first line = count, then t x y z E px py pz pdg per particle.
File16 format: UrQMD header, then r0 rx ry rz p0 px py pz m ityp iso3 ... per particle.
"""
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


def parse_file16(path):
    """Parse UrQMD file16: skip header until pvec, then read particles.
    Each particle: r0,rx,ry,rz, p0,px,py,pz, m, ityp, iso3, ...
    Returns (t,x,y,z,e,px,py,pz) tuples like parse_cola."""
    particles = []
    with open(path) as f:
        for line in f:
            if line.strip().startswith("pvec:"):
                break
        for line in f:
            line = line.strip()
            if not line or line.startswith("E"):
                break
            parts = line.split()
            if len(parts) < 9:
                continue
            try:
                r0, rx, ry, rz = float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])
                p0, px, py, pz = float(parts[4]), float(parts[5]), float(parts[6]), float(parts[7])
                particles.append((r0, rx, ry, rz, p0, px, py, pz))
            except (ValueError, IndexError):
                continue
    return particles


def compare(cola_path, file16_path, tol=1e-4):
    a = parse_cola(cola_path)
    b = parse_file16(file16_path)

    print("=" * 60)
    print("COLA vs pure UrQMD comparison")
    print("=" * 60)
    print(f"COLA ({cola_path}): {len(a)} particles")
    print(f"Pure UrQMD file16 ({file16_path}): {len(b)} particles")
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


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    default_cola = os.path.join(script_dir, "cola_particles.txt")
    default_file16 = os.path.join(script_dir, "reference", "file16")

    if len(sys.argv) >= 3:
        cola_path, file16_path = sys.argv[1], sys.argv[2]
    else:
        cola_path = default_cola
        file16_path = default_file16

    if not os.path.exists(cola_path):
        print(f"Error: {cola_path} not found. Run Runner first (from urqmd-4/).")
        sys.exit(1)
    if not os.path.exists(file16_path):
        print(f"Error: {file16_path} not found. Put pure UrQMD file16 in reference/ or run: ./run_urqmd_pure.sh")
        sys.exit(1)

    ok = compare(cola_path, file16_path)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
