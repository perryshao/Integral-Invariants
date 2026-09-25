#pragma once
#include <cstddef>
#include <stdexcept>
#include <string>
#include <vector>
using mwSize = std::size_t;
struct mxArray
{
    mwSize m, n;
    std::vector<double> data;
    bool real = true, dense = true, dbl = true;
    mxArray(mwSize r, mwSize c) : m(r), n(c), data(r * c) {}
};
constexpr int mxREAL = 0;
inline mxArray *mxCreateDoubleMatrix(mwSize m, mwSize n, int) { return new mxArray(m, n); }
inline double *mxGetPr(const mxArray *a) { return const_cast<double *>(a->data.data()); }
inline mwSize mxGetM(const mxArray *a) { return a->m; }
inline mwSize mxGetN(const mxArray *a) { return a->n; }
inline mwSize mxGetNumberOfDimensions(const mxArray *) { return 2; }
inline mwSize mxGetNumberOfElements(const mxArray *a) { return a->m * a->n; }
inline bool mxIsDouble(const mxArray *a) { return a->dbl; }
inline bool mxIsComplex(const mxArray *a) { return !a->real; }
inline bool mxIsSparse(const mxArray *a) { return !a->dense; }
[[noreturn]] inline void mexErrMsgIdAndTxt(const char *id, const char *, ...)
{
    throw std::runtime_error(id);
}
