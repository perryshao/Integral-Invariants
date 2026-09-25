# Maintaining IID

This is a historical research repository. Preserve descriptor definitions,
experiment parameters, public function names, and existing attribution. Explain
algorithm changes separately from layout changes and validate them numerically.

## Source style

- Use UTF-8, LF line endings, four spaces for indentation, and one final newline.
- Remove trailing whitespace and redundant blank lines. Keep blank lines that
  separate processing stages. Use the checked-in formatter configurations.
- Begin MATLAB function help with its purpose, then explain inputs, outputs,
  units, shape assumptions, and important boundary behavior. Describe actual
  behavior; do not promise invariance or robustness without supporting tests.
- Keep scientific references, upstream attribution, and useful experimental
  parameter alternatives. Avoid comments that merely repeat an assignment.
- Use `clearvars` when a script needs a clean workspace; avoid `clear all`,
  especially inside functions, where workspace cleanup is unnecessary.
- Do not bulk-format `thirdparty/` or edit compiled MEX binaries. Some attributed
  helpers also live outside `thirdparty/`; preserve their notices too.
- Do not globally rename dataset functions: MATLAB resolves these by path and
  current directory. Verify resolution with `which -all` when running experiments.

## Checks

Run from the repository root. Python 3 is sufficient for the hygiene check:

```sh
python3 tools/check_source_hygiene.py
bash -n tools/cleanup_originals.sh
```

MISS_HIT checks the first-party MATLAB tree using `miss_hit.cfg`. Install `uv`
or use an existing MISS_HIT installation. These are static checks, not MATLAB
execution or numerical regression tests. When dependencies are already cached,
add `--offline` after `uv tool run` to avoid network access:

```sh
uv tool run --from miss-hit-core==0.9.44 mh_style --single --brief --input-encoding utf-8 core mbs matching baselines preprocess experiments figures validation utils setup_path.m
uv tool run --from miss-hit==0.9.44 mh_lint --single --brief --input-encoding utf-8 core mbs matching baselines preprocess experiments figures validation utils setup_path.m
```

For C/C++, clang-format 23.1.1 was used with `.clang-format`; pass only source
files outside `thirdparty/`. Check individual files with:

```sh
uv tool run --from clang-format==23.1.1 clang-format --dry-run --Werror mbs/src/Determine_segment.cpp
```

Review formatter diffs, especially MATLAB matrix literals and C macros. Do not
use blanket text replacements for arithmetic spacing. Existing lint findings
and runtime prerequisites are listed in `docs/CODE_REVIEW.md`. Numerical
validation requires MATLAB, compatible MEX binaries, and the external datasets.

`tools/cleanup_originals.sh` is an old destructive archive-maintenance tool with
machine-specific paths. It is not a build or test step; the command above only
checks its shell syntax.

Source archives in `legacy/` also retain their original bytes and encoding.
They are excluded from hygiene checks and are not runtime dependencies.
For executable numerical checks, see [tests/README.md](tests/README.md).
