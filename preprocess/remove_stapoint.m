function [regular_xyz, stapoint_index] = remove_stapoint(curve_xyz)
% REMOVE_STAPOINT Remove consecutive duplicate points and rows with NaN x.
%
%   curve_xyz contains one point per row. Only the FIRST coordinate is
%   checked for NaN. stapoint_index records static rows relative to the
%   NaN-filtered sequence; it does not encode the deleted NaN rows.
%   Input must contain at least one row after NaN filtering.

NaN_index = isnan(curve_xyz);
curve_xyz(NaN_index(:, 1) == 1, :) = [];
double(curve_xyz);
samples = size(curve_xyz, 1);
regular_xyz = [];
regular_xyz(end + 1, :) = curve_xyz(1, :);
stapoint_index = [];
for i = 2:samples
    velocity = norm((curve_xyz(i, :) - curve_xyz(i - 1, :)));
    if velocity > 0
        regular_xyz(end + 1, :) = curve_xyz(i, :); %#ok<AGROW>
    else
        stapoint_index(end + 1) = i; %#ok<AGROW>
    end
end
