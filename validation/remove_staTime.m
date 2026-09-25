function [Gtrajectory_new, Ttrajectory_new] = remove_staTime(Gtrajectory, Ttrajectory)
% REMOVE_STATIME Remove consecutive samples with identical timestamps.
%
%   Gtrajectory contains one sample per row; Ttrajectory is its time vector.
%   The first sample is kept. Numeric NaNs are not removed by this helper.

[samples, m] = size(Gtrajectory);
Gtrajectory_new = zeros(samples, m);
Ttrajectory_new = zeros(samples, 1);
Gtrajectory_new(1, :) = Gtrajectory(1, :);
Ttrajectory_new(1, :) = Ttrajectory(1, :);
indx = samples;
j = 2;
for i = 2:samples
    if Ttrajectory(i) - Ttrajectory(i - 1) == 0
        indx = indx - 1;
    else
        Gtrajectory_new(j, :) = Gtrajectory(i, :);
        Ttrajectory_new(j, :) = Ttrajectory(i, :);
        j = j + 1;
    end
end
Gtrajectory_new(indx + 1:end, :) = [];
Ttrajectory_new(indx + 1:end, :) = [];
