#!/usr/bin/env python3
"""Dataset-free native/Python validation, with optional original-code Octave run.

Usage: python tests/run_validation.py --octave /path/to/octave --report report.json
Requires NumPy, SciPy and a C++ compiler. No shipped MEX binary is overwritten.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import traceback
import numpy as np
from numpy.testing import assert_allclose, assert_array_equal
from scipy.io import savemat, loadmat
from native_runtime import Native, SOURCES
import reference as ref


def run(root, work, octave):
    report = {
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "checks": [],
        "scope": "synthetic numerical/native tests; no real benchmark accuracy claim",
    }

    def check(name, operation):
        try:
            details = operation()
            report["checks"].append({"name": name, "passed": True, "details": details})
            print("PASS", name, flush=True)
        except Exception:
            report["checks"].append(
                {"name": name, "passed": False, "error": traceback.format_exc()}
            )
            print("FAIL", name, traceback.format_exc(), flush=True)

    native = Native(root, work)
    rng = np.random.default_rng(20260925)
    t = np.linspace(0.1, 3.0, 81) ** 1.1
    curve = np.column_stack((np.cos(t), np.sin(t), 0.15 * t + 0.025 * t**2))
    curve2 = np.column_stack((t, np.sin(3 * t), np.cos(2 * t)))
    curve3 = np.column_stack((t**2, np.sin(t), np.cos(4 * t)))
    repeated = np.insert(curve, [10, 10, 40], curve[[10, 10, 40]], axis=0)
    cost = rng.uniform(0.05, 2, (7, 9))

    def normalization():
        clean, restore = ref.remove_static(repeated)
        assert_array_equal(clean, curve)
        assert_array_equal(clean[restore], repeated)
        assert_array_equal(ref.grid(curve), ref.grid(curve * 4 + [8, -4, 2]))

    check("reference preprocessing and grid metamorphic checks", normalization)

    def distances():
        for m, n, d in [(1, 1, 2), (3, 5, 10), (7, 2, 4)]:
            a, b = rng.normal(size=(m, d)), rng.normal(size=(n, d))
            delta = a[:, None, :] - b[None, :, :]
            assert_allclose(native("norm2", a, b)[0], np.linalg.norm(delta, axis=2), atol=1e-12)
            assert_allclose(native("norm1", a, b)[0], np.abs(delta).sum(axis=2), atol=1e-12)
            k, torsion, sk, st = native("kt", a, b, outputs=4)
            for offset, numerator, denominator in [(0, k, sk), (d // 2, torsion, st)]:
                aa, bb = a[:, offset : offset + d // 2], b[:, offset : offset + d // 2]
                assert_allclose(numerator, np.abs(aa[:, None] - bb[None]).sum(axis=2), atol=1e-12)
                assert_allclose(
                    denominator, (np.abs(aa[:, None]) + np.abs(bb[None])).sum(axis=2), atol=1e-12
                )

    check("actual C++ L1/L2/grouped distance vs NumPy", distances)

    def circumcenters():
        for _ in range(30):
            points = rng.normal(size=(3, 3))
            a, b, c = points
            u, v = b - a, c - a
            expected = np.linalg.solve(
                np.vstack((2 * u, 2 * v, np.cross(u, v))), [u @ u, v @ v, 0]
            )
            for count in (1, 2, 3):
                values = native("circumcenter", a, b, c, outputs=count)
                assert_allclose(values[0][0], expected, rtol=1e-10, atol=1e-11)
        for points in (([0, 0, 0], [1, 1, 1], [2, 2, 2]), ([np.nan, 0, 0], [1, 0, 0], [0, 1, 0])):
            try:
                native("circumcenter", *points)
            except ValueError:
                continue
            raise AssertionError("invalid triangle accepted")

    check("actual C++ circumcenter vs linear solve and invalid inputs", circumcenters)

    def dtw_check():
        for shape in [(1, 1), (2, 3), (7, 9), (9, 7), (12, 12)]:
            c = rng.uniform(0.05, 2, shape)
            for window in (0, 2, 100):
                actual = native("dtw", c, [[window]], outputs=2)
                expected = ref.dtw(c, window)
                for a, b in zip(actual, expected):
                    assert_allclose(a, b, rtol=1e-12)
        # Exhaustive paths provide an oracle independent of the DP recurrence.
        c = np.array([[0.2, 1.3, 0.7], [1.1, 0.5, 0.9]])

        def paths(i, j):
            if i == 0 and j == 0:
                return [4 * c[0, 0]]
            costs = []
            for di, dj, weight in ((1, 0, 1), (0, 1, 1), (1, 1, 2)):
                if i >= di and j >= dj:
                    costs.extend(x + weight * c[i, j] for x in paths(i - di, j - dj))
            return costs

        assert_allclose(native("dtw", c, [[100]], outputs=2)[0][-1, -1], min(paths(1, 2)))

    check("actual C++ constrained DTW vs recurrence and exhaustive paths", dtw_check)

    def segment_check():
        line = np.column_stack((np.arange(40), 2 * np.arange(40)))
        for points in (line, line[:, ::-1], line[::-1]):
            a, b = native("segment", points, [[8]], outputs=2)
            assert a[0, 0] == 1 and b[0, 0] == 40
        seg = ref.split_segments(ref.grid(curve), 8, native)
        assert len(seg) > 1
        assert np.all(seg[:, 0] <= seg[:, 1])
        assert np.all(np.diff(seg[:, 0]) >= 0) and np.all(np.diff(seg[:, 1]) >= 0)

    check("actual segment recognizer and bounded 3D segmentation", segment_check)

    def area_check():
        theta = np.linspace(-1.2, 1.2, 81)
        circle = np.column_stack((np.cos(theta), np.sin(theta), np.zeros(81)))
        a = ref.area_stat(circle, 40, 30, 50, 0.3)
        assert 0 < a[0] < 0.5
        # Each intersecting polyline segment drops less than one grid cell.
        # Bound that lost area by cell width times the disk radius per segment.
        intersecting_segments = 2 * np.ceil(np.arcsin(0.3) / (theta[1] - theta[0]))
        rounding_bound = intersecting_segments * (2 / 500) / np.pi
        assert abs(a[1] - 0.5) < rounding_bound
        rotation, _ = np.linalg.qr(rng.normal(size=(3, 3)))
        b = ref.area_stat(circle @ rotation * 3 + [3, 4, 5], 40, 30, 50, 0.9)
        assert_allclose(a, b, atol=0.003)

    check("reference area integral circle and rigid/scale transforms", area_check)
    check(
        "reference distance statistic hand-computed fixture",
        lambda: assert_allclose(
            ref.distance_stat(np.column_stack((np.arange(5), np.zeros((5, 2)))), 1.1, 2), 0.5
        ),
    )
    expected = {}

    def descriptors():
        expected["aii"], expected["segments"] = ref.area_descriptor(curve, native)
        expected["maii"], _ = ref.area_descriptor(curve, native, multiscale=True)
        expected["dii"] = ref.distance_descriptor(curve)
        expected["mdii"] = ref.distance_descriptor(curve, multiscale=True)
        for name, columns in [("aii", 2), ("maii", 10), ("dii", 1), ("mdii", 5)]:
            assert expected[name].shape == (81, columns)
            assert np.all(np.isfinite(expected[name]))
        assert_allclose(expected["maii"][:, 0], expected["maii"][:, 1])
        assert_allclose(expected["mdii"][:, 0], expected["mdii"][:, 1])

    check("reference AII/MAII/DII/MDII and legacy repeated first scale", descriptors)

    def native_sanitizers():
        tests = Path(__file__).parent / "native"
        specs = [
            ("circumcenter", "mbs/src/tricircumcenter3d.cpp", "circumcenter_check.cpp", []),
            ("hull", "mbs/src/MelkmanConvexHull.cpp", "check.cpp", ["-DHULL"]),
            ("orientation", "matching/src/distance_matrix/distance_matrix.cpp", "check.cpp", []),
            (
                "orientation_msrc",
                "matching/src/distance_matrix/distance_matrix_msrc12.cpp",
                "check.cpp",
                ["-DMSRC"],
            ),
        ]
        for name, src, harness, flags in specs:
            target = work / ("sanitize_" + name)
            subprocess.run(
                [
                    "c++",
                    "-std=c++17",
                    "-g",
                    "-fsanitize=address,undefined",
                    "-I" + str(tests),
                    *flags,
                    str(root / src),
                    str(tests / harness),
                    "-o",
                    str(target),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            p = subprocess.run(
                [str(target)],
                capture_output=True,
                text=True,
                timeout=60,
                env={
                    **os.environ,
                    "ASAN_OPTIONS": "detect_leaks=0",
                    "UBSAN_OPTIONS": "halt_on_error=1",
                },
            )
            if p.returncode:
                raise AssertionError(p.stdout + p.stderr)
        return "4 executables, ASan/UBSan; leak checking disabled for platform portability"

    check("native memory/undefined-behavior regressions", native_sanitizers)
    if octave:

        def original_code():
            savemat(
                work / "fixtures.mat",
                dict(curve=curve, curve2=curve2, curve3=curve3, repeated=repeated, cost=cost),
            )

            def quote(path):
                return str(path).replace("'", "''")

            expression = f"addpath('{quote(Path(__file__).parent)}'); run_octave_validation('{quote(root)}', '{quote(work)}');"
            process = subprocess.run(
                [octave, "--no-gui", "--quiet", "--eval", expression],
                capture_output=True,
                text=True,
                timeout=900,
            )
            (work / "octave.log").write_text(process.stdout + process.stderr)
            if process.returncode:
                raise AssertionError(process.stdout + process.stderr)
            result = loadmat(work / "octave_results.mat")
            errors = {}
            for name in ("aii", "maii", "dii", "mdii"):
                errors[name] = float(np.max(np.abs(result[name] - expected[name])))
                assert_allclose(result[name], expected[name], atol=1e-9, rtol=1e-9, err_msg=name)
            assert_array_equal(result["segments"], expected["segments"] + 1)
            assert_array_equal(result["grid_curve"], ref.grid(curve))
            for a, b in zip((result["g"], result["steps"]), ref.dtw(cost, 100)):
                assert_allclose(a, b, rtol=1e-12)
            assert_allclose(
                result["normalized"],
                (curve - curve.min(axis=0)) / np.ptp(curve, axis=0).max(),
                atol=1e-12,
            )
            return {
                "max_absolute_errors": errors,
                "dataset_matchers": ["ASL", "HDM05", "MHAD", "MSRC12"],
                "dataset_scores": result["dataset_scores"].tolist(),
                "dataset_generator_pairs": 4,
                "log": process.stdout[-1500:],
            }

        check("original MATLAB via Octave: descriptors, MEX, files and recognition", original_code)
    else:
        report["octave"] = "not run; Python reference is not proof of MATLAB execution"
    reviewed = set(root / s for s in SOURCES.values())
    for folder in ("core", "preprocess", "matching", "mbs", "tests"):
        reviewed.update(
            p
            for p in (root / folder).rglob("*")
            if p.suffix in {".m", ".cpp", ".h", ".py"} and "__pycache__" not in p.parts
        )
    for dataset in ("ASL", "HDM05", "MHAD", "MSRC12"):
        for name in (
            "dtw_adj_matching.m",
            "feature_dist_matching.m",
            "gene_descriptor_integral.m",
            "gene_descriptor_integral_samples.m",
        ):
            reviewed.add(root / "experiments" / dataset / name)
    report["source_sha256"] = {
        str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(reviewed)
    }
    report["passed"] = all(c["passed"] for c in report["checks"])
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--octave", default=shutil.which("octave"))
    parser.add_argument("--report", type=Path)
    parser.add_argument("--work-dir", type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="iid-validation-") as directory:
        work = args.work_dir or Path(directory)
        work.mkdir(parents=True, exist_ok=True)
        report = run(args.root.resolve(), work.resolve(), args.octave)
        text = json.dumps(report, indent=2) + "\n"
        if args.report:
            args.report.write_text(text)
        print(text)
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
