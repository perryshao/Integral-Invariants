function smooth_curve = fillstapoint(smooth_curve, staindex)
% FILLSTAPOINT Restore repeated rows using static-point indices.
%
%   staindex is the ordered index list returned by remove_stapoint.
%   Each removed static row is restored by repeating the preceding row.
%   Rows discarded because of NaN coordinates are not reconstructed.

n = length(staindex);
for i = 1:n,
    smooth_curve = [smooth_curve(1:staindex(i) - 1, :); smooth_curve(staindex(i) - 1, :); smooth_curve(staindex(i):end, :)]; % insert operation
end
