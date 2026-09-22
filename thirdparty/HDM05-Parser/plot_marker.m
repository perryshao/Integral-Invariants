%% Run this script for ploting the red joints seperately when run skelplay
for i=1:38
    handle(1) = plot3(vals(i, 1), vals(i, 3), vals(i, 2), 'r.');
    axis ij % make sure the left is on the left.
    set(handle(1), 'markersize', 20);
end