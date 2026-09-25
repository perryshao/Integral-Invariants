load occlusion
occlu_ratio = 0.3;
i = 1;
length_trajectory = size(original_trajectory{i}, 1);
occluded_trajectory = original_trajectory{i};
occlu_indx = fix(length_trajectory * rand * (1 - occlu_ratio)) + 1;
occluded_trajectory(occlu_indx:occlu_indx + fix(length_trajectory * occlu_ratio), :) = NaN;

marker_xyz = original_trajectory{i};
marker_des = integral_invariant_kn(marker_xyz, 6, 5);
% marker_des = integral_invariant(marker_xyz,6,0.03);
marker_des(marker_des == 0) = NaN;
marker_des = 0.5 - marker_des;
figure(1)
plot(marker_des(:, 1), '-b.'); hold on;
plot(marker_des(:, 2), '-r.');
axis([0 432 -0.1 0.6]);
figure(2);
plot3d(marker_xyz);
view(-133, 13);

marker_xyz = occluded_trajectory;
marker_des = integral_invariant_kn(marker_xyz, 6, 5);
% marker_des = integral_invariant(marker_xyz,6,0.03);
marker_des(marker_des == 0) = NaN;
marker_des = 0.5 - marker_des;
figure(3);
plot(marker_des(:, 1), '-b.'); hold on;
plot(marker_des(:, 2), '-r.');
axis([0 432 -0.1 0.6])
figure(4);
plot3d(marker_xyz);
view(-133, 13);
axis([-380 273 601 1240 162 1114]);
