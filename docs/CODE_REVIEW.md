# Source review — 2026-09-24

This is the polish-stage snapshot. Subsequent executable validation and runtime
fixes are recorded in [VALIDATION.md](VALIDATION.md); the no-runtime statements
and unresolved circumcenter findings below describe the earlier state.

## Scope and completed changes

The review covered the first-party tree: 314 MATLAB files and 23 C/C++ source
and header files, with static parsing across all MATLAB files and focused manual
inspection of descriptor, preprocessing, matching, MBS, setup, and experiment
entry points. It is not a claim of exhaustive numerical correctness. Existing
uncommitted edits were preserved. Vendor code under `thirdparty/` and compiled
binaries were excluded from formatting. The independent RRV contribution remains.

- Unified indentation, operator/comma spacing, line endings, trailing whitespace,
  and excess blank lines using MATLAB-aware and C/C++ formatters.
- Added concrete input/output and boundary-behavior help to 23 entry points,
  including the core invariant functions. Preserved attribution and research
  parameter alternatives; converted nine legacy C/C++ text encodings to UTF-8.
- Removed DOS EOF characters from `gaussres.m` and `normalis.m` in the ASL Kalman
  helper folder, and a stray `?` in `HDM05/Plot_ResultsMatching.m`. These caused
  MATLAB static parsing errors before formatting.
- Made unsupported descriptor IDs fail explicitly in `validation/cal_descriptors.m`,
  consistent with the existing unsupported-flag errors in dataset generators.
- Replaced remaining script `clear all` calls with `clearvars`, preserving workspace
  cleanup without clearing loaded functions or breakpoints.
- Excluded validation reference variants from `setup_path` and checked that required
  MEX names resolve to compiled functions rather than any same-named MATLAB file.
- Added formatting configuration, maintenance guidance, and a read-only text
  hygiene checker. Corrected README claims that source is still byte-identical
  or that rebuilding on an untested platform is already verified.

## Remaining findings

These need targeted behavioral changes and numerical validation; they were not
changed as part of layout cleanup.

| Priority | Location | Finding and follow-up |
| --- | --- | --- |
| High | `mbs/transform_firstOctant.m` | Three chained comparisons (`-pi < min_octant < -3*pi/4`) evaluate a Boolean against a negative bound. Confirm the intended angular interval, then add boundary tests before changing the geometric transform. |
| High | MEX gateways in `mbs/src` and `matching/src` | Gateways access input/output arrays without consistently validating argument counts, types, or dimensions. Incorrect calls can crash MATLAB. Add gateway validation and rebuild/test each supported platform. |
| High | `mbs/src/tricircumcenter3d.cpp`, `orient2dadapt` | An adaptive orientation path can reach the end of a non-void function without returning. Compare with the attributed upstream robust-predicate implementation and test near-degenerate geometry before repair. |
| Medium | `setup_path.m`, dataset folders | Same-named dataset helpers share the MATLAB path. Work in the intended dataset directory and inspect `which -all`; a future namespacing change needs its own compatibility work. |
| Medium | `preprocess/remove_stapoint.m`, `normalization.m`, `core/curve_grid.m`, `core/Estimate_Frenet.m` | Empty/constant trajectories and degenerate frames are not generally handled. Static-point removal only checks NaN in the first coordinate. The new help documents these assumptions. |
| Medium | `experiments/MHAD/comparison_samples.m` | Main function is named `trajectory_matching`; it also uses `TRAJDB` and `index` without defining them or accepting them as inputs. Treat as an incomplete exploratory driver. |
| Medium | ASL `BayesianKalmanFilter/normalis.m` | Main function is named `normalise`. Resolve the historical alias and callers before renaming. |
| Medium | HDM05/MHAD descriptor generator pairs | Some reference/test MBS thickness values differ (8 vs 20 or 6 vs 20). Preserve historical values until the intended experiment is confirmed. |
| Medium | Dataset loading and optional baselines | Several scripts continue after reporting missing data. Dataset files and some optional baseline dependencies are external; a parse pass does not make every experiment runnable. |
| Reference | `validation/variants/val3_*.m` | Six filename/function-name mismatches belong to archived variants. They remain readable but are excluded from the default path. |

## Validation and limits

Final checks (MISS_HIT 0.9.44):

| Check | Result |
| --- | --- |
| MATLAB style and parsing | 314 files; no remaining style or parse issues under the checked-in rules. |
| MATLAB lint | 314 files; 11 known findings described below. |
| Text hygiene | 346 files; zero issues. |
| MATLAB code-token comparison | 314 files; zero unexpected differences after accounting for the documented edits. |
| C/C++ code-token comparison | 23 files; zero differences, excluding comments and macro line continuations. |
| Third-party directory | No Git content differences from HEAD; historical checkout line endings may differ from stored blobs. |
| MEX files | All 43 tracked MEX-related files match HEAD byte for byte. |
| Shell/Python syntax | `bash -n tools/cleanup_originals.sh` and Python AST parsing passed. |
| Git whitespace check | `git diff --check` passed. |

All 314 MATLAB files were parsed with MISS_HIT. Lint reports three high-priority
chained-relation findings and eight filename/function-name findings listed above.
Formatting checks and the repository hygiene checker are separate from these
known semantic warnings. C/C++ formatting used clang-format 23.1.1 with include
order preserved. Code-token comparisons against a pre-polish local snapshot
check that formatting did not change expressions; explicit fixes, script
workspace cleanup, setup changes, and redundant matrix row separators are
accounted for separately. Token comparisons do not prove numerical equivalence.

MATLAB/Octave execution, MEX compilation, dataset recognition runs, and published
accuracy reproduction were not performed: no runnable MATLAB/Octave command was
available in the inspected environment. Old platform-specific binaries alone
are not evidence of compatibility with the current host.

Local review checkpoint (not a portable repository dependency):
`/tmp/iid-polish-20260924-153003`, including `existing.patch` and pre-polish source
copies. Temporary diagnostic logs use `/tmp/iid-style-*.log` and
`/tmp/iid-lint.log`; they may be removed by the operating system.
