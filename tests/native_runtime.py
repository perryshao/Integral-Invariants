"""Build/load actual repository C++ through a deliberately small test MEX shim."""
import ctypes
from pathlib import Path
import subprocess
import numpy as np

SOURCES = {
    "segment": "mbs/src/Determine_segment.cpp",
    "circumcenter": "mbs/src/tricircumcenter3d.cpp",
    "dtw": "matching/src/dtwpath/dtwpath.cpp",
    "norm1": "matching/src/distance_matrix/distance_matrix_norm1.cpp",
    "norm2": "matching/src/distance_matrix/distance_matrix_norm2.cpp",
    "kt": "matching/src/distance_matrix/distance_matrix_kt.cpp",
}


class Native:
    def __init__(self, root, build):
        self.libs = {}
        headers = Path(__file__).parent / "native"
        for name, source in SOURCES.items():
            target = Path(build) / (name + ".so")
            subprocess.run(
                [
                    "c++",
                    "-std=c++17",
                    "-O1",
                    "-shared",
                    "-fPIC",
                    "-I" + str(headers),
                    str(root / source),
                    str(headers / "bridge.cpp"),
                    "-o",
                    str(target),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            library = ctypes.CDLL(str(target))
            integer = ctypes.POINTER(ctypes.c_int)
            doubles = ctypes.POINTER(ctypes.c_double)
            library.iid_run.argtypes = [
                ctypes.c_int,
                integer,
                integer,
                ctypes.POINTER(doubles),
                ctypes.c_int,
                ctypes.POINTER(doubles),
                integer,
                integer,
            ]
            library.iid_run.restype = ctypes.c_int
            library.iid_free.argtypes = [doubles]
            self.libs[name] = library

    def __call__(self, name, *arrays, outputs=1):
        arrays = [np.asfortranarray(np.atleast_2d(a), dtype=np.float64) for a in arrays]
        integer = ctypes.c_int
        pointer = ctypes.POINTER(ctypes.c_double)
        rows = (integer * len(arrays))(*(a.shape[0] for a in arrays))
        cols = (integer * len(arrays))(*(a.shape[1] for a in arrays))
        inputs = (pointer * len(arrays))(*(a.ctypes.data_as(pointer) for a in arrays))
        result = (pointer * outputs)()
        out_rows, out_cols = (integer * outputs)(), (integer * outputs)()
        lib = self.libs[name]
        status = lib.iid_run(len(arrays), rows, cols, inputs, outputs, result, out_rows, out_cols)
        if status:
            raise ValueError("MEX rejected input: " + name)
        values = []
        for i in range(outputs):
            values.append(
                np.ctypeslib.as_array(result[i], shape=(out_rows[i] * out_cols[i],))
                .copy()
                .reshape((out_rows[i], out_cols[i]), order="F")
            )
            lib.iid_free(result[i])
        return values
