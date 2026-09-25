function integral = integral_invariant_dist_ms(Curve_xyz, Radius)
% INTEGRAL_INVARIANT_DIST_MS Compute distance invariants at five radius scales.
%
%   Curve_xyz is normalised before integration. Radius is halved at each
%   scale. Output has five columns; uncomputed boundaries remain zero.
%   Static-point rows removed during preprocessing are restored.

[Curve_xyz, staindex] = remove_stapoint(Curve_xyz); % for occlusion
Curve_xyz = normalization(Curve_xyz); % just for radius-based variant
n = size(Curve_xyz, 1);
multscale = 5;
integral = zeros(n, multscale);
%% compute the integral invariants
for i = 2:(n - 2)
    r = Radius;
    for j = 1:multscale
        integral(i, j) = estimate_integral_dist(Curve_xyz, r, i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
        r = r / 2;
    end
end
integral = fillstapoint(integral, staindex);
