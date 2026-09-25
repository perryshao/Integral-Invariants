# Executable validation — 2026-09-25

## Outcome and scope

This extends the earlier Cross-View-Learning approach (syntax/static checks and
structure-preserving comparisons) with executable numerical tests. The suite
combines actual C++ sources, independent NumPy calculations, and GNU Octave
10.3.0 execution of the original MATLAB functions. See the checked-in
[JSON results](VALIDATION_RESULTS.json) and [reproduction instructions](../tests/README.md).

The synthetic pipeline covers trajectory preprocessing, grid conversion, 3-D
maximal blurred segments, local frames, AII/MAII/DII/MDII descriptors, saved/loaded
MAT files, DTW matching and nearest-neighbour selection. It runs all four dataset
matcher entry points and the four shipped train/test integral-descriptor generator
pairs. The fixture has 81 points; the three synthetic query classes undergo
rotation, translation and uniform scaling before matching.

This is not a full benchmark reproduction. Raw ASL/HDM05/MHAD/MSRC12 readers,
real dataset splits, every alternative descriptor/baseline, the archived 2-D
fallback, visualization scripts and published recognition rates are outside
this run. Octave compatibility does not prove MATLAB ABI/toolbox compatibility.

## Verified behavior

- Core AII, MAII, DII and MDII outputs agree with NumPy to below 1e-9 absolute and
  relative tolerances; the run records the observed maximum errors in JSON.
  The Python area oracle uses an independent linear solve for circumcenters,
  but deliberately shares the actual native segment recognizer.
- C++ L1/L2/grouped distances match NumPy. Thirty random triangles exercise each
  of the circumcenter's one/two/three-output forms against a linear-system oracle.
- C++ constrained DTW matches a reference recurrence across five matrix shapes
  and three window widths, plus an exhaustive small-path calculation.
- Four ASan/UBSan executables cover the circumcenter output-buffer regression,
  recovered batch/incremental Melkman hulls (including 1201 input points), and
  generic/MSRC12 orientation distances with numerical and invalid-input fixtures.
- Real Octave MEX builds execute the MATLAB code rather than replacing its
  functions with Python stubs. Static-row handling, frame finiteness, descriptor
  dimensions, removed flag rejection, traceback and MAT interchange are checked.
- All four dataset matchers select the expected labels for transformed synthetic
  queries. The actual default generators produce equal finite train/test outputs:
  ASL 4 columns, HDM05 1, MHAD 20 and MSRC12 10.
- MISS_HIT parses/formats 316 MATLAB files with no remaining configured style
  issues. Lint still reports the 11 historical findings in CODE_REVIEW.md.
  Text hygiene and Git whitespace checks also pass for active project code.

## Runtime defects fixed

1. **Circumcenter MEX output overrun.** `Estimate_Frenet` and `estimate_integral`
   request one output, but `tricircumcenter3d.cpp` previously wrote `plhs[1]` and
   `plhs[2]` unconditionally. An exact-sized native output buffer reproduced an
   AddressSanitizer heap-buffer-overflow before the fix. Optional outputs are now
   allocated only when requested; one/two/three-output regression tests pass.
2. **Undefined return from a truncated predicate.** The archived `orient2dadapt`
   has an unfinished near-degenerate branch. It now raises
   `IID:unresolvedOrientation` instead of returning undefined data. This is a
   fail-closed guard, not restoration of a complete exact-arithmetic predicate.
   Non-finite inputs and collinear/overflowing triangles also receive explicit
   errors. Ordinary triangle formulas and descriptor parameters are unchanged.
3. **Missing structure constructor.** The active 2-D and 3-D segment entry points
   called an unavailable `structure` helper. They now construct the same scalar
   fields with MATLAB's built-in `struct`; 3-D runtime execution is verified.
   The rest of the legacy 2-D path is not certified by that change.

Historical MEX binaries are preserved byte-for-byte. They do **not** contain the
new circumcenter fix. Rebuild the source on the actual MATLAB platform before
using that fix in MATLAB; the test builds stay outside the normal project path.

## Preserved historical behavior and open risks

- The index-based multiscale routines repeat the initial radius at scales 1 and 2.
  Both implementations reproduce this behavior, and the tests expose it. Changing
  the scale schedule would alter historical descriptors and needs a separate
  scientific decision.
- DTW initializes its padded origin to twice the first local cost, then charges
  the first diagonal step again. Its band also uses the historical shifted
  indices. These conventions are tested and retained, not silently standardized.
- `estimate_integral` drops fractional grid cells per polyline segment. A planar
  circle fixture has rectifying area about 0.484 rather than exactly 0.5. The
  sanity test uses the derived bound of one lost integration cell per segment;
  it does not claim an exact analytic integral.
- Some dataset matchers convert NaN local distances to zero. Empty, constant,
  degenerate or unusually long inputs, MBS fixed buffers, several other MEX
  gateways, and alternative experiment parameters still need dedicated work.
- The three chained comparisons and eight filename/name mismatches remain as
  documented in the earlier review. No synthetic test certifies every branch.
- Compile warnings include the MBS base class's non-virtual destructor. The
  suite is not a proof that every native memory path is safe.

## Reproducibility and provenance

The JSON report includes hashes of the exercised sources and test files. Python
3.11, NumPy 1.26.4, SciPy 1.11.4, Apple Clang and GNU Octave 10.3.0 were used.
No benchmark data or generated descriptors are added to Git. The recovered active
C++ sources were formatted and their installed hashes updated while retaining
original archive hashes. `legacy/` remains a byte-preserved source archive and is
excluded from active-code formatting checks.

Homebrew could not install Octave on the host OS. Conda provided an isolated
installation; a packaging relocation defect in its launcher/compiler flags was
worked around using temporary environment variables documented in tests/README.md.
These environment failures were not IID algorithm failures.
