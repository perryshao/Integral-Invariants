// Test-only adapter: execute the repository MEX source, not a reimplementation.
#include "mex.h"
#include <algorithm>
#include <exception>
#include <vector>
extern void mexFunction(int, mxArray **, int, const mxArray **);
extern "C" int iid_run(int nrhs, const int *rows, const int *cols, const double **data, int nlhs,
                       double **result, int *out_rows, int *out_cols)
{
    std::vector<mxArray *> owned;
    std::vector<const mxArray *> inputs;
    std::vector<mxArray *> outputs(nlhs, nullptr);
    try
    {
        for (int i = 0; i < nrhs; ++i)
        {
            auto *a = new mxArray(rows[i], cols[i]);
            std::copy(data[i], data[i] + rows[i] * cols[i], a->data.begin());
            owned.push_back(a);
            inputs.push_back(a);
        }
        mexFunction(nlhs, outputs.data(), nrhs, inputs.data());
        for (int i = 0; i < nlhs; ++i)
        {
            if (!outputs[i])
                throw std::runtime_error("missing output");
            out_rows[i] = outputs[i]->m;
            out_cols[i] = outputs[i]->n;
            result[i] = new double[outputs[i]->data.size()];
            std::copy(outputs[i]->data.begin(), outputs[i]->data.end(), result[i]);
        }
    }
    catch (const std::exception &)
    {
        for (auto *p : owned)
            delete p;
        for (auto *p : outputs)
            delete p;
        return 1;
    }
    for (auto *p : owned)
        delete p;
    for (auto *p : outputs)
        delete p;
    return 0;
}
extern "C" void iid_free(double *p) { delete[] p; }
