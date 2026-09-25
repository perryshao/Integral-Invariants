#include "mex.h"
#include <cassert>
#include <cmath>
#include <iostream>
#include <limits>
extern void mexFunction(int, mxArray **, int, const mxArray **);
void rejected(int nlhs, int nrhs, const mxArray **in)
{
    mxArray *out[9] = {};
    bool failed = false;
    try
    {
        mexFunction(nlhs, out, nrhs, in);
    }
    catch (const std::runtime_error &)
    {
        failed = true;
    }
    for (auto p : out)
        delete p;
    assert(failed);
}
int main()
{
#ifdef HULL
    for (int count : {3, 4, 20, 1201})
    {
        mxArray pts(count, 2);
        for (int i = 0; i < count; ++i)
        {
            double a = 6.283185307179586 * i / count;
            pts.data[i] = std::cos(a);
            pts.data[count + i] = std::sin(a);
        }
        const mxArray *in[] = {&pts};
        mxArray *out[1] = {};
        mexFunction(1, out, 1, in);
        assert(out[0]->m == static_cast<mwSize>(count + 1));
        assert(out[0]->n == 2);
        for (int i = 0; i < count; ++i)
        {
            bool found = false;
            for (mwSize j = 0; j < out[0]->m; ++j)
                if (std::abs(pts.data[i] - out[0]->data[j]) < 1e-12 &&
                    std::abs(pts.data[count + i] - out[0]->data[out[0]->m + j]) < 1e-12)
                    found = true;
            assert(found);
        }
        // Append one outside point using the public incremental interface.
        mxArray next(1, 2);
        next.data = {3, 0};
        const mxArray *inc[] = {out[0], &next};
        mxArray *grown[1] = {};
        mexFunction(1, grown, 2, inc);
        bool found = false;
        for (mwSize j = 0; j < grown[0]->m; ++j)
            if (grown[0]->data[j] == 3 && grown[0]->data[grown[0]->m + j] == 0)
                found = true;
        assert(found);
        delete grown[0];
        delete out[0];
    }
    mxArray p(3, 2);
    p.data = {0, 1, 0, 0, 0, 1};
    const mxArray *in[] = {&p};
    rejected(0, 1, in);
    rejected(1, 0, in);
    p.dense = false;
    rejected(1, 1, in);
    p.dense = true;
    p.data[0] = std::numeric_limits<double>::quiet_NaN();
    rejected(1, 1, in);
    p.data = {0, 1, 2, 0, 1, 2};
    rejected(1, 1, in);
    std::cout << "PASS hull: batch/incremental, 1201 points, "
                 "shape/type/arity/degenerate guards\n";
#else
    for (int trial = 0; trial < 12; ++trial)
    {
        mxArray a(3, 4), b(2, 4), u(3, 9), v(2, 9);
        for (mwSize i = 0; i < a.data.size(); ++i)
            a.data[i] = std::sin(i + trial) * 3;
        for (mwSize i = 0; i < b.data.size(); ++i)
            b.data[i] = std::cos(i + trial) * 2;
        for (mwSize i = 0; i < u.data.size(); ++i)
            u.data[i] = std::sin(i + trial) * 3;
        for (mwSize i = 0; i < v.data.size(); ++i)
            v.data[i] = std::cos(i + trial) * 3;
        const mxArray *in[] = {&a, &b, &u, &v};
        mxArray *out[9] = {};
        mexFunction(8, out, 4, in);
        assert(out[8] == nullptr);
        for (int i = 0; i < 3; ++i)
            for (int j = 0; j < 2; ++j)
            {
                double e[8] = {};
                for (int k = 0; k < 2; ++k)
                {
                    double x = a.data[k * 3 + i], y = b.data[k * 2 + j];
                    e[0] += std::abs(x - y);
                    e[4] += std::abs(x) + std::abs(y);
                    x = a.data[(k + 2) * 3 + i];
                    y = b.data[(k + 2) * 2 + j];
                    e[1] += std::abs(x - y);
                    e[5] += std::abs(x) + std::abs(y);
                }
                for (int k = 0; k < 9; ++k)
                {
                    double x = u.data[k * 3 + i], y = v.data[k * 2 + j];
                    bool radial =
#ifdef MSRC
                        k == 2 || k == 5;
#else
                        (k + 1) % 3 == 0;
#endif
                    if (radial)
                    {
                        e[3] += std::abs(x - y);
                        e[7] += std::abs(x) + std::abs(y);
                    }
                    else
                    {
                        double d = x - y;
                        if (d > 3.141592653589793)
                            d -= 6.283185307179586;
                        if (d < -3.141592653589793)
                            d += 6.283185307179586;
                        e[2] += std::abs(d);
                        e[6] += std::abs(x) + std::abs(y);
                    }
                }
                for (int k = 0; k < 8; ++k)
                    assert(std::abs(out[k]->data[j * 3 + i] - e[k]) < 1e-11);
            }
        for (auto p : out)
            delete p;
        for (auto &p : out)
            p = nullptr;
        mexFunction(9, out, 4, in);
        assert(out[8]->data.size() == 2 && out[8]->data[0] == 0);
        for (auto p : out)
            delete p;
        rejected(7, 4, in);
        rejected(8, 3, in);
        a.dense = false;
        rejected(8, 4, in);
        a.dense = true;
        v.n = 8;
        rejected(8, 4, in);
    }
    std::cout << "PASS distance: 12 numeric fixtures, 8/9-output contract and "
                 "invalid-input guards\n";
#endif
}
