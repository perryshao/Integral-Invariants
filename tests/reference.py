"""Explicit NumPy reference for the legacy IID formulas; not production code.

Native segment recognition is supplied by the caller. MATLAB rounding, endpoint
exclusion, duplicated centre samples and the historical scale schedule are kept.
"""
import numpy as np


def remove_static(points):
    points = np.asarray(points, dtype=float)
    points = points[~np.isnan(points[:, 0])]
    keep = np.r_[True, np.any(np.diff(points, axis=0) != 0, axis=1)]
    return points[keep], np.cumsum(keep) - 1


def grid(points, width=1000):
    scaled = (points - points.min(axis=0)) / np.ptp(points, axis=0).max() * width
    return np.floor(scaled + 0.5)


def distance_stat(points, radius, pos):
    samples = []
    for direction, stop in ((-1, 0), (1, len(points) - 1)):
        k = pos
        while k != stop and np.linalg.norm(points[k] - points[pos]) <= radius:
            samples.append(np.linalg.norm(points[k] - points[pos]))
            k += direction
    if not samples:
        return np.nan
    if not any(samples):
        return 0.0
    return np.mean(samples) / np.ptp(samples)


def distance_descriptor(points, kpoints=32, multiscale=False):
    points, restore = remove_static(points)
    result = np.zeros((len(points), 5 if multiscale else 1))
    half = kpoints // 2
    for i in range(half, len(points) - half):
        distances = [
            np.linalg.norm(points[i] - points[i - half]),
            np.linalg.norm(points[i + half] - points[i]),
        ]
        radius = max(distances) if multiscale else min(distances)
        for j in range(result.shape[1]):
            result[i, j] = distance_stat(points, radius, i)
            k = kpoints // (2 ** (j + 1))
            radius = max(
                np.linalg.norm(points[i] - points[i - k]),
                np.linalg.norm(points[i + k] - points[i]),
            )
    return result[restore] if multiscale else result


def split_segments(points, width, native):
    """Mirror splitting_curve_3D control flow with a bounded loop for diagnostics."""
    n = len(points)
    k, start = 1, 0

    def endpoint(a, b):
        return min(
            int(
                native("segment", points[a : b + 1, [0, c]], np.array([[width]]), outputs=2)[1][
                    0, 0
                ]
            )
            for c in (1, 2)
        )

    while k < n:
        end = endpoint(0, k)
        if end < k + 1 or k == n - 1:
            break
        k += 1
    segments = [(0, end - 1)]
    attempts = 0
    while k < n - 1:
        while k < n - 1:
            start += 1
            attempts += 1
            if attempts > n * n or start > k:
                raise AssertionError("MBS failed to progress")
            if endpoint(start, k) == k - start + 1:
                break
        while k < n - 1:
            k += 1
            if endpoint(start, k) < k - start + 1:
                break
        segments.append((start, k - 1))
    return np.asarray(segments)


def neighbours(n, segments):
    left = np.full(n, -1, dtype=int)
    right = np.full(n, -1, dtype=int)
    for i, (begin, end) in enumerate(segments):
        a = 0 if i == 0 else segments[i - 1, 1] + 1
        b = n if i == len(segments) - 1 else segments[i + 1, 0]
        left[a : end + 1] = begin
        right[begin:b] = end
    return left, right


def frame(points, centre, left, right):
    """Independent circumcenter via a 3x3 linear system, not the C++ formula."""
    a, b, c = points[[left, centre, right]]
    u, v = b - a, c - a
    cross = np.cross(u, v)
    offset = np.linalg.solve(np.vstack((2 * u, 2 * v, cross)), [u @ u, v @ v, 0.0])
    normal = a + offset - b
    normal /= np.linalg.norm(normal)
    binormal = cross / np.linalg.norm(cross)
    return np.cross(normal, binormal), normal, binormal


def area_stat(points, pos, left, right, radius):
    tangent, normal, binormal = frame(points, pos, left, right)
    spacing = 2 * radius / 500
    result = []
    for axis, height_axis in ((binormal, normal), (normal, binormal)):
        projected = points - ((points - points[pos]) @ axis)[:, None] * axis
        total = 0.0
        for direction in (-1, 1):
            k = pos
            while (0 < k if direction < 0 else k < len(points) - 1) and np.linalg.norm(
                projected[k] - projected[pos]
            ) <= radius:
                delta = direction * (projected[k + direction] - projected[k])
                length = np.linalg.norm(delta)
                cosine = delta @ tangent / (length * np.linalg.norm(tangent))
                if not np.isfinite(cosine) or cosine == 0:
                    k += direction
                    continue
                step = spacing / cosine
                count = int(np.trunc(length / step))
                indices = np.arange(1, abs(count) + 1) * np.sign(count)
                samples = projected[k] + direction * indices[:, None] * step * delta / length
                vectors = samples - projected[pos]
                vectors = vectors[np.linalg.norm(vectors, axis=1) < radius]
                heights = (
                    np.sqrt(np.abs(radius**2 - (vectors @ tangent) ** 2)) - vectors @ height_axis
                )
                total += np.sum(spacing * heights) * np.sign(step)
                k += direction
        result.append(total / (np.pi * radius**2))
    return np.array([1 - result[0] if result[0] > 0.5 else result[0], abs(result[1])])


def area_descriptor(points, native, width=8, kpoints=32, multiscale=False):
    points, restore = remove_static(points)
    segments = split_segments(grid(points), width, native)
    left, right = neighbours(len(points), segments)
    result = np.full((len(points), 10 if multiscale else 2), 0.5)
    half = kpoints // 2
    for i in range(half, len(points) - half):
        assert left[i] >= 0 and right[i] >= 0
        distances = [
            np.linalg.norm(points[i] - points[i - half]),
            np.linalg.norm(points[i + half] - points[i]),
        ]
        radius = max(distances) if multiscale else min(distances)
        for j in range(5 if multiscale else 1):
            value = area_stat(points, i, left[i], right[i], radius)
            if multiscale:
                result[i, [j, j + 5]] = value
            else:
                result[i] = value
            k = kpoints // (2 ** (j + 1))
            radius = max(
                np.linalg.norm(points[i] - points[i - k]),
                np.linalg.norm(points[i + k] - points[i]),
            )
    return result[restore], segments


def dtw(cost, window):
    """Independent recurrence; retains doubled origin cost and historical band."""
    m, n = cost.shape
    acc = np.full((m + 1, n + 1), np.finfo(float).max)
    steps = np.zeros((m, n))
    acc[0, 0] = 2 * cost[0, 0]
    with np.errstate(over="ignore"):
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if abs(i + 1 - (j + 1) / (n / m)) > window:
                    continue
                v = cost[i - 1, j - 1]
                choices = [acc[i, j - 1] + v, acc[i - 1, j - 1] + 2 * v, acc[i - 1, j] + v]
                choice = 0 if choices[0] < choices[1] else 1
                if choices[choice] > choices[2]:
                    choice = 2
                acc[i, j] = choices[choice]
                steps[i - 1, j - 1] = choice + 1
    return acc, steps
