function trajectory = transform_add_noise(trajectory, occlu_flag, level)

marker_xyz = trajectory;

theta_x = 30; tx = 200; % in degree
theta_y = 0; ty = 100;
theta_z = 45; tz = 0;
s = 0.5; % scale factor

mindim = min([max(marker_xyz(:, 1)) - min(marker_xyz(:, 1))...
              max(marker_xyz(:, 2)) - min(marker_xyz(:, 2))...
              max(marker_xyz(:, 3)) - min(marker_xyz(:, 3))]);
maxdim = max([max(marker_xyz(:, 1)) - min(marker_xyz(:, 1))...
              max(marker_xyz(:, 2)) - min(marker_xyz(:, 2))...
              max(marker_xyz(:, 3)) - min(marker_xyz(:, 3))]);
marker_xyz(:, 1) = marker_xyz(:, 1) + (level * randn(1, size(marker_xyz, 1)) * sqrt(mindim))';
marker_xyz(:, 2) = marker_xyz(:, 2) + (level * randn(1, size(marker_xyz, 1)) * sqrt(mindim))';
marker_xyz(:, 3) = marker_xyz(:, 3) + (level * randn(1, size(marker_xyz, 1)) * sqrt(mindim))';

marker_xyz(:, end + 1) = 1; % qici matrix
marker_xyz = marker_xyz';
marker_xyz = makehgtform('xrotate', (theta_x * pi) / 180) * marker_xyz;
marker_xyz = makehgtform('yrotate', (theta_y * pi) / 180) * marker_xyz;
marker_xyz = makehgtform('zrotate', (theta_z * pi) / 180) * marker_xyz;
marker_xyz = makehgtform('translate', tx, ty, tz) * marker_xyz;
marker_xyz = makehgtform('scale', s) * marker_xyz;
marker_xyz = marker_xyz';
marker_xyz(:, end) = [];

trajectory = marker_xyz;

% cut the trajectory with occlu_ratio occlusion
if occlu_flag == 1
    length_trajectory = size(trajectory, 1);
    occlu_indx = fix(length_trajectory * rand * (1 - occlu_ratio)) + 1;
    trajectory(occlu_indx:occlu_indx + fix(length_trajectory * occlu_ratio), :) = NaN;
end
