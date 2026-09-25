function [curvegrid, grid] = curve_grid(curve_xyz, width)
% CURVE_GRID Translate and discretise a curve using uniform grid spacing.
%
%   curve_xyz is an N-by-D coordinate matrix. width divides the largest
%   coordinate range; grid is the resulting spacing in input units.
%   curvegrid contains rounded, translated grid coordinates. Constant
%   trajectories have zero spacing and require handling by the caller.

n = size(curve_xyz, 1);
curve_limit = max(curve_xyz, [], 1) - min(curve_xyz, [], 1);
max_limit = max(curve_limit);
grid = max_limit / width;
curvegrid = (curve_xyz - repmat(min(curve_xyz, [], 1), n, 1)) ./ grid;
curvegrid = round(curvegrid);
