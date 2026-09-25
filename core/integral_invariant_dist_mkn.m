function integral = integral_invariant_dist_mkn(Curve_xyz, kpoints)
% INTEGRAL_INVARIANT_DIST_MKN Compute distance invariants using five neighbourhood scales.
%
%   Curve_xyz contains trajectory coordinates; kpoints sets the initial
%   index neighbourhood. Radii are derived from endpoint distances.
%   Output has five columns and zero boundary padding. Static rows are
%   restored; rows removed for NaN coordinates are not restored.

[Curve_xyz, staindex] = remove_stapoint(Curve_xyz); % for occlusion
n = size(Curve_xyz, 1);
multscale = 5;
integral = zeros(n, multscale);
%% compute the integral invariants
kns_i = fix(kpoints / 2);
for i = kns_i + 1:(n - kns_i)
    r = max(norm(Curve_xyz(i, :) - Curve_xyz(i - kns_i, :)), norm(Curve_xyz(i + kns_i, :) - Curve_xyz(i, :)));
    for j = 1:multscale
        integral(i, j) = estimate_integral_dist(Curve_xyz, r, i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
        %     integral(i,:) = estimate_integral_ellipse(Curve_xyz,Curve_xyz(i,:),Curve_xyz(L(i),:),Curve_xyz(R(i),:),Radius,0,i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
        %     integral(i,:) = estimate_integral_fig(Curve_xyz,Curve_xyz(i,:),Curve_xyz(L(i),:),Curve_xyz(R(i),:),Radius,i);
        kns = fix(kpoints / (2^j));
        r = max(norm(Curve_xyz(i, :) - Curve_xyz(i - kns, :)), norm(Curve_xyz(i + kns, :) - Curve_xyz(i, :)));
    end
end
integral = fillstapoint(integral, staindex);
