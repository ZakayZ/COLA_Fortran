# URQMD Parameters (pmap)

All parameters are passed via the COLA ParametersMap (pmap) in the Create call, e.g.:

```cpp
filter->Create({
    {"Ap", "197"}, {"At", "197"}, {"Zp", "79"}, {"Zt", "79"},
    {"ebeam", "100"}, {"bimp", "5"}, {"seed", "12345"},
    {"nsteps", "200"}, {"dtimestep", "0.2"}, {"eos", "0"},
    {"ctp_1", "1.0"}, {"cto_30", "1"}
});
```

---

## Run-level parameters

### pro / tar – projectile and target nuclei

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| Ap | int | 197 | Projectile mass number |
| Zp | int | 79 | Projectile charge |
| At | int | 197 | Target mass number |
| Zt | int | 79 | Target charge |

### PRO / TAR – special projectile/target (single particle)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pro_special | int | 0 | 1 = use special projectile |
| spityp_p | int | 0 | UrQMD particle type (ityp) for projectile |
| spiso3_p | int | 0 | Isospin 2×I₃ for projectile |
| tar_special | int | 0 | 1 = use special target |
| spityp_t | int | 0 | UrQMD particle type for target |
| spiso3_t | int | 0 | Isospin 2×I₃ for target |

### nev – number of events

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nev | int | 1 | Number of events |

### tim – propagation time

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| tottime | float | — | Total propagation time (fm/c) |
| outtime | float | — | Output interval (fm/c) |
| nsteps | int | 200 | Number of timesteps (alternative to tottime) |
| dtimestep | float | 0.2 | Timestep (fm/c) |

### ene / plb / ecm – beam energy or momentum

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ebeam | float | 100.0 | Lab kinetic energy per nucleon (GeV) |
| pbeam | float | — | Lab beam momentum per nucleon (GeV/c) |
| srt | float | — | √s for two-particle collision (GeV) |
| srtmin | float | — | √s excitation function: min (GeV) |
| srtmax | float | — | √s excitation function: max (GeV) |
| nsrt | int | 1 | √s excitation function: number of points |
| pbmin | float | — | PLB excitation: min momentum (GeV/c) |
| pbmax | float | — | PLB excitation: max momentum (GeV/c) |
| npb | int | 1 | PLB excitation: number of bins |

### imp / IMP – impact parameter

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bimp | float | 5.0 | Fixed impact parameter (fm) |
| bmin | float | — | IMP: minimum impact parameter (fm) |
| bmax | float | — | IMP: maximum impact parameter (fm) |
| imp_random | int | 0 | 1 = sample b randomly in [bmin, bmax] |

### eos – equation of state

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| eos | int | 0 | 0=cascade, 1=Skyrme, etc. |

### box – infinite-matter box

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| box | int | 0 | 1 = enable box mode |
| lbox | float | — | Box edge length (fm) |
| edens | float | — | Energy density (GeV/fm³) for bpe |
| solid | int | 0 | 1 = solid walls |
| para | int | 0 | 1 = periodic boundaries |

### bpt – box particle population (momentum cutoff)

| Key | Type | Description |
|-----|------|-------------|
| bpt_N | "ityp iso3 npart pmax" | Box species N: UrQMD ityp, iso3, particle count, max momentum (GeV/c) |

Example: `{"bpt_1", "1 2 100 2.5"}` = 100 protons (ityp=1, iso3=2), max p=2.5 GeV/c

### bpe – box particle population (energy density)

| Key | Type | Description |
|-----|------|-------------|
| bpe_N | "ityp iso3 npart" | Box species N: uses global edens |

Example: `{"bpe_1", "1 2 50"}` = 50 protons with edens from box

### rsd / cdt / stb

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| seed | int | 12345 | Random seed (≤0: auto from time) |
| cdt | float | — | Collision timestep (fm/c), overrides dtimestep |
| stb | int | — | Keep particle with this ityp stable |
| stb_N | int | — | Same, for multiple species (stb_1, stb_2, …) |

---

## CTParam (ctp_N)

Set via `ctp_1`, `ctp_2`, … `ctp_83`. All values are real (double).

| Index | Default | Description |
|-------|---------|-------------|
| 1 | 1.0 | Scaling factor for decay width |
| 2 | 0.77 | Minimal string mass & el/inel cut in makestr |
| 3 | 2.0 | Velocity exponent for modified AQM |
| 4 | 0.3 | Transverse pion mass (makestr, strexct) |
| 5 | 0.0 | Probability for quark rearrangement in cluster |
| 6 | 0.37 | Strangeness probability |
| 7 | 0.0 | Charm probability (not yet implemented) |
| 8 | 0.093 | Probability to create a diquark |
| 9 | 0.35 | Kinetic energy cut off for last string break |
| 10 | 0.25 | Min. kinetic energy for hadron in string |
| 11 | 0.0 | Fraction of non groundstate resonances |
| 12 | 0.5 | Probability for rho 770 in string |
| 13 | 0.27 | Probability for rho 1450 |
| 14 | 0.49 | Probability for omega 782 |
| 15 | 0.27 | Probability for omega 1420 |
| 16 | 1.0 | Mass cut between rho770 and rho1450 |
| 17 | 1.6 | Mass cut between rho1450 and rho1700 |
| 18 | 0.85 | Mass cut between omega 782 and omega1420 |
| 19 | 1.55 | Mass cut between omega1420 and omega1600 |
| 20 | 0.0 | Distance for second projectile |
| 21 | 0.0 | Deformation parameter |
| 25 | 0.9 | Probability for diquark not to break |
| 26 | 50 | Max trials to get string masses |
| 27 | 1.0 | Scaling factor for xmin in string excitation |
| 28 | 1.0 | Scaling factor for transverse Fermi motion |
| 29 | 1.0 | Double strange diquark suppression factor |
| 30 | 1.5 | Radius offset for initialisation |
| 31 | 1.6 | Sigma of Gaussian for transverse momentum transfer |
| 32 | 0.0 | Alpha-1 for valence quark distribution |
| 33 | 2.5 | Betav for valence quark distribution (DPM) |
| 34 | 0.1 | Minimal x multiplied with ecm |
| 35 | 3.0 | Offset for cut for FSM |
| 36 | 0.275 | Fragmentation function parameter a |
| 37 | 0.42 | Fragmentation function parameter b |
| 38 | 1.08 | Diquark pt scaling factor |
| 39 | 0.8 | Strange quark pt scaling factor |
| 40 | 0.5 | Betas-1 for valence quark distribution (LEM) |
| 41 | 0.0 | Distance of initialisation |
| 42 | 0.55 | Width of Gaussian → pt in string fragmentation |
| 43 | 5.0 | Max kinetic energy in mesonic cluster |
| 44 | 0.8 | Prob. double vs. single excitation for AQM inel. |
| 45 | 0.5 | Offset for minimal mass generation of strings |
| 46 | 800000 | Max number of rejections for initialisation |
| 47 | 1.0 | Field Feynman fragmentation funct. param. a |
| 48 | 2.0 | Field Feynman fragmentation funct. param. b |
| 49 | 0.5 | Additional single strange diquark suppression |
| 50 | 1.0 | Enhancement factor for 0⁻ mesons |
| 51 | 1.0 | Enhancement factor for 1⁻ mesons |
| 52 | 1.0 | Enhancement factor for 0⁺ mesons |
| 53 | 1.0 | Enhancement factor for 1⁺ mesons |
| 54 | 1.0 | Enhancement factor for 2⁺ mesons |
| 55 | 1.0 | Enhancement factor for 1⁺ mesons |
| 56 | 1.0 | Enhancement factor for 1⁻* mesons |
| 57 | 1.0 | Enhancement factor for 1⁻* mesons |
| 58 | 1.0 | Scaling factor for DP time-delay |
| 59 | 0.7 | Scaling factor for leading hadron x-section (PYTHIA) |
| 60 | 3.0 | Resonance/string transition energy for s-channel |
| 61 | 0.2 | Cell size for hydro grid (fm/c) |
| 62 | 200 | Total hydro grid size (number of cells) |
| 63 | 1.0 | Minimal hydro start time |
| 64 | 5.0 | Factor for freezeout criterium (x*e0) |
| 65 | 1.0 | Factor for variation of thydro_start |
| 66 | 1e10 | Rapidity cut for initial state |
| 67 | 1.0 | Number of test particles per real particle |
| 68 | 1.0 | Width of 3d-Gauss for hydro initial state mapping |
| 69 | 0.0 | Quark density cut for initial state |
| 70 | 1e10 | Cut in pseudorapidity range for core density |
| 71 | 2.0 | Hypersurface determined every nth timestep |
| 72 | 0.55 | Ratio Sigma0/(Sigma0+Lambda0) in s-exchange |
| 74 | 0.0 | Scaling for x-section non-leading string hadrons |
| 75 | 1.0 | Lower cutoff for pressure in hydro [e0] |
| 76 | 38.87 | Parameter 1 for QMD-EoS |
| 77 | 17.72 | Parameter 2 for QMD-EoS |
| 78 | -3.97 | Parameter 3 for QMD-EoS |
| 79 | -0.315 | Parameter 4 for QMD-EoS |
| 80 | 0.268 | Parameter 5 for QMD-EoS |
| 81 | -0.041 | Parameter 6 for QMD-EoS |
| 82 | 0.002 | Parameter 7 for QMD-EoS |
| 83 | 1.143 | Minimum distance in potential initialisation |

---

## CTOption (cto_N)

Set via `cto_1`, `cto_2`, … `cto_68`. All values are integers.

| Index | Default | Description |
|-------|---------|-------------|
| 1 | 0 | Resonance widths mass dependent |
| 2 | 0 | Conservation of scattering plane |
| 3 | 0 | Use modified detailed balance |
| 4 | 0 | No initial config output |
| 5 | 0 | Fixed impact parameter |
| 6 | 0 | No first collisions inside proj/target |
| 7 | 0 | Elastic cross section enabled |
| 8 | 0 | Extrapolate branching ratios |
| 9 | 0 | Use tabulated pp cross sections |
| 10 | 0 | Enable Pauli blocker |
| 11 | 0 | Mass reduction for cascade initialisation |
| 12 | 0 | String condition (≠0: no strings) |
| 13 | 0 | Enhanced file16 output |
| 14 | 0 | cos(θ) distributed between -1..1 |
| 15 | 0 | Allow mm & mb scattering |
| 16 | 0 | Propagate without collisions |
| 17 | 0 | Colload after every timestep |
| 18 | 0 | Final decay of unstable particles |
| 19 | 0 | Allow bbar annihilation |
| 20 | 0 | Don't generate e+e⁻ instead of bbar |
| 21 | 0 | Use Field Feynman fragmentation function |
| 22 | 1 | Use Lund excitation function |
| 23 | 0 | Lorentz contraction of projectile & target |
| 24 | 1 | Wood-Saxon initialisation |
| 25 | 0 | Phase space corrections for resonance mass |
| 26 | 0 | Use z→1-z for diquark pairs |
| 27 | 0 | Reference frame (1=target, 2=projectile, else=CMS) |
| 28 | 0 | Propagate spectators also |
| 29 | 2 | No transverse momentum in cluster |
| 30 | 1 | Frozen Fermi motion |
| 31 | 0 | Reduced mass spectrum in string |
| 32 | 0 | Masses distributed acc. to m-dep. widths |
| 33 | 0 | Use tables & m-dep. for pmean in fprwdt & fwidth |
| 34 | 1 | Lifetime according to m-dep. width |
| 35 | 1 | Generate high precision tables |
| 36 | 0 | Normalize Breit-Wigners with m-dep. widths |
| 37 | 0 | Heavy quarks form diquark clusters |
| 38 | 0 | Scale p-pbar to b-bbar with equal p_lab |
| 39 | 0 | Don't call Pauli blocker |
| 40 | 0 | Read old fort.14 file |
| 41 | 0 | Generate extended output for cto40 |
| 42 | 0 | Hadrons have color fluctuations |
| 43 | 0 | Don't generate dimuon instead of dielectron |
| 44 | 1 | Call PYTHIA for hard scatterings |
| 45 | 0 | Hydro mode |
| 46 | 0 | Calculate quark density instead of baryon density |
| 47 | 5 | Flag for equation of state for hydro |
| 48 | 0 | Propagate only N timesteps of hydro |
| 49 | 0 | Propagate spectators with hydrodynamics |
| 50 | 0 | Additional f14/f19 output after hydro phase |
| 52 | 0 | Freezeout procedure changed |
| 53 | 0 | Efficient momentum generation in Cooper-Frye |
| 54 | 0 | OSCAR output during hydro evolution |
| 55 | 0 | f19 output adjusted for visualization |
| 56 | 0 | f15 output has unique particle id |
| 57 | 1 | Legacy event header w/ missing cto and ctp |
| 58 | 0 | Standard event header in collision file (file15) |
| 59 | 1 | Activate baryon-baryon strangeness exchange |
| 60 | 0 | Use 20% isotropic x-section in inelastic coll. |
| 61 | 0 | No inelastic N+N scattering |
| 62 | 0 | Perform resonance decays before each output step |
| 63 | 0 | Use tabulated CMF EoS for QMD evolution |
| 64 | 0 | Output nuclei from coalescence in f13 and OSCAR |
| 65 | 0 | Use parametrized EoS for QMD evolution |
| 66 | 0 | Include mesons in Coulomb potentials |
| 67 | 0 | Energy cut for counting participants in elastic |
| 68 | 0 | Reconstruct resonances for f13 output |
