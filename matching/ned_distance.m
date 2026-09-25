function d = ned_distance(t, r)
% NED_DISTANCE Sum Damerau edit distances across corresponding columns.
%
%   t and r contain the sequences to compare column by column.
%   Requires edit_distance_damerau from the bundled edit_distances toolbox.

m = size(t, 2);
d = 0;
for i = 1:m
    d = d + edit_distance_damerau(t(:, i), r(:, i));
end
