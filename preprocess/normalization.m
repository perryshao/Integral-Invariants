function [Curve_xyz, max_limit, min_original] = normalization(Curve_xyz)
% NORMALIZATION Translate a trajectory and scale by its largest axis range.
%
%   Rows are points. min_original is the original per-axis minimum and
%   max_limit is the common scale divisor. The largest coordinate range
%   becomes one. Constant trajectories divide by zero in this legacy
%   implementation; callers must reject or handle them explicitly.

n = size(Curve_xyz, 1);
m = size(Curve_xyz, 2);
Curve_limit = max(Curve_xyz, [], 1) - min(Curve_xyz, [], 1);
min_original = min(Curve_xyz, [], 1);
max_limit = max(Curve_limit);
Curve_xyz = (Curve_xyz - repmat(min(Curve_xyz, [], 1), n, 1)) ./ repmat(max_limit, n, m);
