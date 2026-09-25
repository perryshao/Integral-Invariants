#include "mex.h"
#include <cassert>
#include <cmath>
#include <iostream>
extern void mexFunction(int, mxArray **, int, const mxArray **);
int main()
{
    mxArray a(1, 3), b(1, 3), c(1, 3);
    a.data = {0, 0, 0};
    b.data = {2, 0, 0};
    c.data = {0, 2, 0};
    const mxArray *in[] = {&a, &b, &c};
    for (int n : {1, 2, 3})
    {
        auto **out = new mxArray *[n]();
        mexFunction(n, out, 3, in);
        assert(std::abs(out[0]->data[0] - 1) < 1e-12);
        assert(std::abs(out[0]->data[1] - 1) < 1e-12);
        for (int i = 0; i < n; ++i)
            delete out[i];
        delete[] out;
    }
    std::cout << "PASS circumcenter: 1/2/3 outputs\n";
}
