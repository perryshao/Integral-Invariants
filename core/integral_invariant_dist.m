function integral = integral_invariant_dist(Curve_xyz, kpoints)
% INTEGRAL_INVARIANT_DIST Compute a single-scale distance integral descriptor.
%
%   Curve_xyz contains one 3-D point per row. kpoints defines a symmetric
%   index neighbourhood; the smaller endpoint distance sets the radius.
%   Output is one column with zero padding at uncomputed boundaries.
%   Unlike the multiscale variants, this legacy function does NOT restore
%   removed static-point rows. Callers must account for its shorter output.

[Curve_xyz, ~] = remove_stapoint(Curve_xyz); % for occlusion
n = size(Curve_xyz, 1);
integral = zeros(n, 1);

%% compute the integral invariants
kns = fix(kpoints / 2);
for i = kns + 1:(n - kns)
    Radius = min(norm(Curve_xyz(i, :) - Curve_xyz(i - kns, :)), norm(Curve_xyz(i + kns, :) - Curve_xyz(i, :)));
    integral(i, 1) = estimate_integral_dist(Curve_xyz, Radius, i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
end
