# Executable validation without MATLAB

Use Python 3.11, a C++ compiler, and optionally GNU Octave with its MEX compiler.
The suite writes all generated data and rebuilt binaries to temporary storage;
it never loads or overwrites the historical binaries in `mbs/bin` or `matching/bin`.

```sh
python3.11 -m venv .venv
.venv/bin/pip install -r tests/requirements.txt
.venv/bin/python tests/run_validation.py --report /tmp/iid-native-results.json
.venv/bin/python tests/run_validation.py --octave /path/to/octave-cli --report /tmp/iid-full-results.json
```

Pass `--work-dir /tmp/iid-run` to retain build files, fixtures, MAT outputs, and
`octave.log` for diagnosis. An explicit invalid Octave path is a failure; when
Octave is not provided or discoverable, only the native/Python checks run and
the JSON report explicitly records the missing original-code execution.

## What the tests establish

- `native_runtime.py` compiles the actual MEX sources and calls them through a
  small test-only API shim. Distance matrices are compared with NumPy broadcasting,
  circumcenters with an independent linear-system solution, and constrained DTW
  with a reference recurrence plus exhaustive enumeration of a small example.
- Four separate native executables use AddressSanitizer and UndefinedBehaviorSanitizer
  for the circumcenter output contract and recovered hull/orientation kernels.
  Leak detection is disabled for cross-platform compatibility. The shim is not
  a MATLAB ABI replacement and these checks are not MATLAB runtime tests.
- `reference.py` is an explicit test oracle for the historical descriptor formulas.
  It intentionally retains duplicated centre samples, boundary padding, the
  repeated first multiscale radius, and the legacy DTW origin/band convention.
  It uses the actual native MBS recognizer; MBS is therefore not an independent
  algorithm reimplementation. Circumcenters in the area oracle use a linear solve.
- `run_octave_validation.m` builds seven real Octave MEX modules, executes original
  MATLAB preprocessing, MBS, frame, area/distance descriptor and DTW functions,
  and compares their outputs with Python. It checks MAT serialization, all four
  dataset matchers on transformed synthetic queries, and four actual train/test
  descriptor-generator pairs on synthetic input files.
- The default generators are tested as shipped: ASL AII (four channels including
  differences), HDM05 DII (one), MHAD MAII (twenty including differences), and
  MSRC12 MAII (ten). This does not certify every optional descriptor switch or
  the original dataset readers and benchmark split/evaluation scripts.

Synthetic curves have 81 points and nondegenerate local frames. AII/MAII/DII/MDII
cross-language comparison uses absolute and relative tolerances of 1e-9. The
circle-area sanity check uses a bound based on the number of dropped integration
grid cells, rather than assuming the discretized integral equals an analytic area.

The test on transformed queries is a three-class synthetic nearest-neighbour
check, not a reported benchmark accuracy. MATLAB itself, its toolboxes, legacy
Windows binaries, raw dataset readers, optional baselines and full paper results
still require their original environment and data.

## Local Conda/macOS workaround used in this review

Homebrew rejected the host macOS version. An isolated Conda Octave 10.3.0
installation was used instead. Its relocated launcher/compiler flags contained
embedded NUL padding. Calling `octave-cli` and overriding the temporary build
variables avoided that packaging defect without patching Octave or project code:

```sh
export OCTAVE_HOME=/tmp/iid-octave
export OCTAVE_EXEC_HOME=/tmp/iid-octave
export CPPFLAGS=-DIID_VALIDATION_BUILD
export CFLAGS=-O2
export CXXFLAGS='-O2 -std=c++17'
export XTRA_CFLAGS=-fPIC
export XTRA_CXXFLAGS=-fPIC
export LDFLAGS='-L/tmp/iid-octave/lib -Wl,-rpath,/tmp/iid-octave/lib'
export DL_LDFLAGS='-bundle -Wl,-undefined,dynamic_lookup'
```

These overrides are specific to that macOS environment; do not apply the bundle
linker flags on Linux. A normal Octave installation should use its own compiler
configuration. `octave_include/matrix.h` is a test-only compatibility include for
Octave's matrix API, which is already declared by its `mex.h`.
