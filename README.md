# IID — Integral Invariants for 3-D Motion Trajectory Description

MATLAB/C++ implementation of **integral invariants** for describing, matching and
recognising 3-D motion trajectories, together with the four experiment suites and the
baseline descriptors used for comparison.

This directory is a consolidated, **code-only** reconstruction of a project that was
previously spread across a networked MATLAB workspace and several local folders.
Intermediate results (`.mat`), figures (`.fig`/`.tif`/`.png`) and raw datasets are
deliberately **not** included — see [Provenance](#provenance) and [Datasets](#datasets).

---

## Papers

The code implements the methods in the following three papers:

| # | Paper | Venue |
|---|-------|-------|
| 1 | *On Integral Invariants for Effective 3-D Motion Trajectory Matching and Recognition* | IEEE Trans. Cybernetics, 46(2):511–523, Feb 2016 |
| 2 | *Integral Invariants for Space Motion Trajectory Matching and Recognition* | Pattern Recognition, 48(8):2418–2432, 2015 |
| 3 | *Multiscale Integral Invariant for Motion Trajectory Matching and Recognition* | IEEE ICMA 2014, pp. 126–131 |

Authors: Zhanpeng Shao, Y. F. Li — Dept. of Mechanical and Biomedical Engineering,
City University of Hong Kong.

## Licence

GPL-3.0 — see [`LICENSE`](LICENSE). The third-party toolboxes under `thirdparty/`
keep their own licences; see [`thirdparty/README.md`](thirdparty/README.md).

The MBS component (`mbs/`) was previously published standalone as the
`Maximal-Blurred-Segments` repository, also under GPL-3.0; that repository has been
retired now that its contents are carried here. Its sources are identical apart from
the include paths, which were flattened (`"lib\unit_reco.h"` → `"unit_reco.h"`) to
match this project's layout, and both `.mexa64` binaries are byte-identical.

---

## Method at a glance

A 3-D motion trajectory `γ(t) = {x(t), y(t), z(t)}` is described by **line integrals of a
kernel function along the trajectory**, which avoids the high-order derivatives that make
differential invariants noise-sensitive.

```
  raw 3-D trajectory
        │
        ├─ preprocess/   normalise, remove static points, resample to integer grid
        │
        ├─ mbs/          Maximal Blurred Segment (MBS) decomposition of the noisy
        │                discrete curve  →  stable left/right key points
        │
        ├─ core/         Estimate_Frenet:  Frenet–Serret frame (t, n, b) per point
        │                                   from the MBS key points
        │                │
        │                ├─ integral_invariant_dist*  →  distance integral invariant (DII)
        │                │     ball kernel B_r, mean distance to neighbours
        │                │
        │                └─ integral_invariant*       →  area integral invariant (II)
        │                      areas cut on the osculating plane P_O and the
        │                      rectifying plane P_R, bounded by the ball kernel B_r
        │                      ( *_ms / *_mkn  →  multiscale, radius halved per level )
        │
        └─ matching/     DTW (dpcore / dtwpath / traceback_path) over the invariant
                         sequences  →  distance matrix  →  1-NN classification
```

Two kernels give two invariant families, both invariant to translation, rotation,
reflection and (after normalisation) scaling, and insensitive to noise and partial
occlusion because the integration is restricted to a local ball neighbourhood.

---

## Directory layout

```
IID/
├── core/          Integral invariant definition + estimation + Frenet–Serret frame
├── mbs/           Maximal Blurred Segment: 3-D discrete line segmentation
│   ├── src/         C++ sources (Determine_segment, tricircumcenter3d, unit_reco)
│   └── bin/         prebuilt mex: maci64 / a64 / w32 / w64
├── matching/      DTW distance, distance matrices, edit / histogram distances
│   ├── src/         C++ sources (dpcore, dtwpath, distance_matrix_*, hist_isect_c)
│   └── bin/         prebuilt mex
├── baselines/     Comparison descriptors (see table below)
├── preprocess/    Normalisation, interpolation, resampling, occlusion generation
├── experiments/   One folder per dataset — HDM05 / MHAD / ASL / MSRC12
├── figures/       Scripts that generate the paper figures
│   └── variants/    Divergent copies of core files kept for reproducibility (see Notes)
├── validation/    2021 OptiTrack / trakSTAR sensor-validation study (see below)
├── utils/         Plotting, confusion matrices, SVM training wrappers
├── thirdparty/    Code-only subsets of the external toolboxes the pipeline calls
└── tools/         Maintenance scripts (original-location cleanup)
```

### `validation/` — not part of the three papers

A later (2021) study that reused these invariants to compare an OptiTrack Motive rig
against a trakSTAR magnetic tracker, in a 4-phase recording protocol.

| Item | What it is |
|---|---|
| `run_val1.m`, `run_val2.m`, `run_matching.m` | experiment drivers |
| `cal_descriptors.m` | descriptor computation for the validation trajectories |
| `remove_NaNpoint.m`, `remove_staTime.m` | preprocessing helpers unique to this study |
| `protocol/Dividers_*.txt` | phase-boundary timestamps defining the 4 recording phases |
| `ToZP/` | RRV (relative rotation vector) descriptor — a separate contribution |
| `variants/val3_*.m` | that study's forks of six functions that also exist in `core/` |

This code was rescued from the original `Validation 3 Clean` folder, where it existed in
no other location. The OptiTrack/trakSTAR recordings themselves
(`.mat`/`.csv`/`.xlsx`/`.fig`) were not kept.

`remove_NaNpoint` and `remove_staTime` belong to this study only — they clean **raw
sensor-capture artifacts** (empty cells in the tracker's CSV export, and consecutive
frames sharing a timestamp) and take cell-array / separate-time-vector inputs rather
than the `Curve_xyz` N×3 form the rest of the project uses. Nothing in `core/`, `mbs/`,
`matching/`, `baselines/`, `preprocess/` or `experiments/` calls them. Do not confuse
them with `preprocess/remove_stapoint.m`, which *is* core infrastructure.

### Core functions

| Function | Invariant |
|---|---|
| `integral_invariant` | area integral invariant, fixed radius (normalised radius) |
| `integral_invariant_kn` | area integral invariant, radius in grid units (**k**ernel **n**umber) |
| `integral_invariant_ms` / `_mkn` | **m**ulti**s**cale area integral invariant |
| `integral_invariant_dist` | distance integral invariant (DII) |
| `integral_invariant_dist_ms` / `_dist_mkn` | multiscale distance integral invariant |
| `estimate_integral*` | numerical estimation of the above (grid accumulation) |
| `Estimate_Frenet` | Frenet–Serret frame `(t, n, b)` estimated via MBS |

Common signature: `I = integral_invariant_kn(Curve_xyz, Width, Radius)` where
`Width` is the MBS segmentation width `v` (papers use `v = 8`, sometimes `6`/`10`) and
`Radius` is the ball-kernel radius `r`.

---

## Running the experiments

```matlab
cd IID
setup_path            % adds every subfolder to the MATLAB path
```

Each `experiments/<DATASET>/` folder follows the same pattern:

| Step | Function |
|---|---|
| 1. load dataset | `load_c3d_bat` / `load_bvh_bat` / `load_txt_bat` / `load_sign_bat` |
| 2. preprocess | `preprocess_bat` |
| 3. build descriptors | `gene_descriptor_integral`, `gene_descriptor_fd`, … |
| 4. match / recognise | `trajectory_matching`, `recognition_dtw_*_bat` |
| 5. report | `drawPRC`, `Plot_ResultsMatching`, `Get_ClusterAccuracy` |

`matching_test.m` is the batch driver that sweeps noise level and occlusion ratio.

### Descriptor selection

`trajectory_matching(marker, level, descrip_flag, occlu_ratio)` — `descrip_flag`
selects which descriptor is evaluated, which is how the comparison tables in the papers
were produced:

| flag | Descriptor |
|---|---|
| 1 | Fourier descriptor (FD) |
| 2 | Differential invariants (DI) — `descriptor_comp` |
| 3 | **Area integral invariant (II)** — `integral_invariant_kn` |
| 4 | **Multiscale integral invariant (MII)** — `integral_invariant_ms` |
| 5 | **Distance integral invariant (DII)** — `integral_invariant_dist` |
| 6 | Multiscale distance integral invariant — `integral_invariant_dist_mkn` |
| 8 | 3-D shape context on Frenet frames — `sc3d_compute` |
| 9 | Moment invariants — `Moment_Invariant` |

`level` is the additive Gaussian noise standard deviation; `occlu_ratio` is the
simulated occlusion ratio.

Note that `gene_descriptor_integral` does *not* mean the same descriptor in every
experiment folder — it is whichever block was last enabled (ASL: AII, HDM05: DII, MHAD and
MSRC12: MAII). Check the active line before trusting a result. Train/test generator
pairs (`foo.m` / `foo_samples.m`) must select the same block; a mismatch produces
meaningless recognition rates rather than an error.

`self_similarity.m` (HDM05, MHAD, MSRC12) builds a pairwise distance matrix among one
sample's descriptors via `feature_dist_matching`; it is called by
`thirdparty/SpectralClustering/RankOneDecom_Feaures.m`, which every `recognition_dtw_*`
script depends on.

---

## Datasets

Datasets are **not** bundled. Obtain them from the original sources and point the
`load_*` scripts at them:

| Folder | Dataset | Used for |
|---|---|---|
| `experiments/HDM05` | HDM05 mocap (Univ. Bonn, C3D/BVH) | trajectory matching, noise, occlusion |
| `experiments/MHAD` | Berkeley MHAD | trajectory matching, noise, occlusion |
| `experiments/ASL` | Auslan / ASL sign archive (UCI KDD) | sign-language recognition |
| `experiments/MSRC12` | MSRC-12 Kinect Gesture | gesture recognition |

---

## Building the mex files

Prebuilt binaries are in `mbs/bin/` and `matching/bin/` for `maci64`, `glnxa64`,
`win32` and `win64`. Not every target exists for every function — see the table below.
To rebuild from source:

```matlab
cd mbs/src
mex Determine_segment.cpp unit_reco.cpp
mex tricircumcenter3d.cpp

cd ../../matching/src/dtwpath
mex dpcore.cpp
mex dtwpath.cpp

cd ../distance_matrix
mex distance_matrix_norm1.cpp
mex distance_matrix_norm2.cpp
mex distance_matrix_kt.cpp

cd ..
mex hist_isect_c.c
```

`stdafx.cpp` / `stdafx.h` / `targetver.h` are Visual Studio precompiled-header stubs and
are only needed for a Windows build.

### Binary / source coverage

| Function | source | maci64 | glnxa64 | win32/64 |
|---|---|---|---|---|
| `Determine_segment` (MBS) | ✅ | ✅ | ✅ | ✅ |
| `tricircumcenter3d` | ✅ | ✅ | ✅ | ✅ |
| `dpcore`, `dtwpath` | ✅ | ✅ | — | ✅ |
| `distance_matrix_norm1/norm2/kt` | ✅ | ✅ | — | win32 |
| `hist_isect_c` | ✅ | — | — | ✅ |
| `MelkmanConvexHull` | ❌ **no source** | — | — | ✅ |

### ⚠️ Two known gaps

**1. The macOS binaries are Intel, this machine is Apple Silicon.**
Every `.mexmaci64` here is `Mach-O 64-bit bundle x86_64`. Under an Apple-Silicon MATLAB
(`maca64`) they will not load. Everything except `MelkmanConvexHull` has
source in `mbs/src/` and `matching/src/`, so rebuild with the `mex` commands above —
that is the intended fix, not Rosetta.

**2. `MelkmanConvexHull` exists only as Windows binaries — no source.**

- `MelkmanConvexHull` implements the convex-hull dynamical-thickness test used by the
  **pure-MATLAB** MBS path: `Determine_xy` / `Determine_xz`, reached from
  `splitting_curve_2D` (2-D trajectories) and from the `splitting_curve_3D_mat` variant.
  The **main 3-D pipeline is unaffected** — `splitting_curve_3D` calls the
  `Determine_segment` mex, which does have source. So 3-D trajectory work rebuilds
  cleanly; only the 2-D and pure-MATLAB fallback paths are blocked off-Windows.

---

## Third-party dependencies

`thirdparty/` holds code-only subsets of the six toolboxes the published pipeline
actually calls (1.8 MB). Each keeps its own licence — see
[`thirdparty/README.md`](thirdparty/README.md).

| Folder | Used by |
|---|---|
| `C3D`, `c3d_matlab` | `load_c3d*` — reading HDM05 / MHAD mocap |
| `HDM05-Parser` | `load_bvh_bat` |
| `mocap-bvh-toolbox` | `bvhReadFile`, `skel2xyz`, used by `HDM05-Parser` |
| `SpectralClustering` | every `recognition_dtw_*` script |
| `PG_Curve-master` | `draw_cm`, `compute_precision_recall` — confusion matrices, PR curves |
| `edit_distances` | `matching/ned_distance.m` |

### Not bundled

All three papers classify with **1-NN over the DTW inter-descriptor distance**. SVM,
HMM, bag-of-visual-words and sparse coding were explored but never used for a published
result, and none of their entry points is called by anything in this project, so
`libsvm`, `bnt`, `HMMall`, `computeBoV`, `ScSPM` and `fast_sc` are not included
(2050 files, 11 MB — and with `bnt`, a GPL dependency).

Twelve scripts still reference them and cannot run without installing the toolbox
first: `utils/train_libsvm.m`, `experiments/ASL/recognition_dtw_tsd_bat.m`,
`{ASL,MSRC12}/mhmm_classifier.m`, `ASL/mhmm_classifier_cluster.m`,
`MSRC12/trainHMM.m`, `{ASL,MSRC12}/gene_codebook.m`, `gene_codebook_pyramid.m` and
`gene_codebook_ScSPM.m`. Sources are listed in `thirdparty/README.md`.

---

## Provenance

| IID folder | Came from |
|---|---|
| `core/`, `mbs/*.m`, `matching/*.m`, `baselines/`, `preprocess/`, `utils/` | top level of `OneTouch/MatlabProjects/work/` |
| `mbs/src/`, `mbs/bin/*.mexa64`, `*.mexmaci64` | local `Determine_segment_Linux/`, `Determine_segment_Mac/` |
| `matching/src/`, `matching/bin/*.mexmaci64` | local `Validation 3 Clean/{dtwpath_c, distance_matrix, tricircumcenter_c}` |
| `experiments/*` | `work/{HDM05,MHAD,ASL,MicrosoftGesture}EvaluatingCode/` — `.m`/`.cpp`/`.h`/mex only |
| `figures/` | `work/analysis data/` + `work/` top level |
| `validation/` | local `Validation 3 Clean/` — every `.m` and `ToZP/` file that existed nowhere else |
| `thirdparty/` | `work/` toolboxes, code-only subsets |

All three local source folders were verified byte-for-byte against IID before any
cleanup; every code file they held is reproduced here.
`Determine_segment_Linux/` and `Determine_segment_Mac/` were 100 % redundant and removed.
`Validation 3 Clean/` was reduced to code only (186 MB → ~0.5 MB) rather than removed —
its original `ToZP/` RRV descriptor is kept in place by request.
`mbs/bin/tricircumcenter3d.val3build.mexmaci64` is a second build of the same source
kept from `Validation 3 Clean` for completeness.

### Notes on `figures/variants/`

The core routines existed in **three** copies. `work/` top level and
`Validation 3 Clean/` are byte-identical for most files and are treated as canonical
(that is what `core/` holds). `work/analysis data/` held **modified** copies used to
render the paper figures, and three files differ across all three copies:
`integral_invariant_kn.m`, `integral_invariant_mkn.m`, `splitting_curve_3D.m`.

Rather than silently discard those forks, they are preserved in `figures/variants/`
(`val3_*` prefix = the `Validation 3 Clean` fork). If a figure fails to reproduce from
`core/`, compare against the corresponding variant.

### Deliberately excluded

- All `.mat` intermediates, `.fig`/`.tif`/`.png` figures, and raw dataset files.
- `.asv` MATLAB autosave backups.
- `MHADEvaluatingCode/demo_depth/` — the MHAD dataset's own demo plus Bouguet's camera
  calibration toolbox; not referenced by any code kept here.
- Projects that share the workspace but do not use these invariants: depth-map I/O,
  MSRAction3D, TUM Kitchen, sparse-coding demos, `IPEvaluatingCode`.
- The OptiTrack / trakSTAR recordings from the 2021 validation study — its **code** is
  kept in `validation/`, but the `.mat`/`.csv`/`.xlsx`/`.fig` recordings are not.
  (Those 6 `.fig` files alone were 163 MB of the folder's 186 MB.)
