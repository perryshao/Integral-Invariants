clearvars;
data_folder = 'tsd_data_bat/not-my-problem/';  % LOCATION OF C3D FILES
file_ext = '.tsd';
fidin = fopen(strcat(data_folder, '9-not-my-problem-3.tsd'));
fidout = fopen('mkmatlab.txt', 'w');
i = 1;
while ~feof(fidin)
    tline = fgetl(fidin);
    tline = str2num(tline);
    fprintf(fidout, '%s\n', tline);
    mk(i, :) = tline;
    i = i + 1;
    continue
end
x = mk(:, 1) * 10e3; y = mk(:, 2) * 10e3; z = mk(:, 3) * 10e3;
x1 = mk(:, 12) * 10e3; y1 = mk(:, 13) * 10e3; z1 = mk(:, 14) * 10e3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% moving average filter

% x=movave(x,5);y=movave(y,5);z=movave(z,5);
% x1=movave(x1,5);y1=movave(y1,5);z1=movave(z1,5);
% x=x'; y=y'; z=z';
% x1=x1';y1=y1';z1=z1';

%%%%%%%%%%%%%%%%%%%%%%%%%% another method of kalman filter
ss = 6; % state size
os = 3; % observation size
F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
H = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0];
Q = 0.05 * eye(ss);
R = 1 * eye(os);
initx = [x(1) y(1) z(1) 0.05 0.05 0.05]';
initV = 1 * eye(ss);
[marker_smooth, ~, ~, ~] = kalman_smoother([x y z]', F, H, Q, R, initx, initV);
x = marker_smooth(1, :)';
y = marker_smooth(2, :)';
z = marker_smooth(3, :)';

initx = [x1(1) y1(1) z1(1) 0.05 0.05 0.05]';
initV = 1 * eye(ss);
[marker_smooth, ~, ~, loglik] = kalman_smoother([x1 y1 z1]', F, H, Q, R, initx, initV);
x1 = marker_smooth(1, :)';
y1 = marker_smooth(2, :)';
z1 = marker_smooth(3, :)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
right_curve1 = [x y z];
left_curve1 = [x1 y1 z1];
%% db4 wavelet filter
% right_curve1=wav_filter(right_curve1);
% left_curve1=wav_filter(left_curve1);

% right_curve1=interpolation(right_curve1,2*size(right_curve1,1),0);
% left_curve1=interpolation(left_curve1,2*size(left_curve1,1),0);
figure(1);
Right = plot3(right_curve1(:, 1), right_curve1(:, 2), right_curve1(:, 3), '.r-'); hold on; grid on;
Left = plot3(left_curve1(:, 1), left_curve1(:, 2), left_curve1(:, 3), 'xb-'); hold on;
axis image, view(3), legend([Right Left], {'Right Hand', 'Left Hand'});
[orientation1, r1] = gene_relative_descrip(right_curve1, left_curve1);
% orientation1 = [sin(orientation1(:,1)).*cos(orientation1(:,2))...
%      sin(orientation1(:,1)).*sin(orientation1(:,2)) cos(orientation1(:,1))];
save variable1 orientation1 r1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot the curve
% figure(1);
% plot3(right_curve1(1,1),right_curve1(1,2),right_curve1(1,3),'--ro');
% hold on;
% subplot(2,1,1),plot3(right_curve1(:,1),right_curve1(:,2),right_curve1(:,3),'--b*');grid on;
% hold on;
% subplot(2,1,2),plot3(left_curve1(1,1),left_curve1(1,2),left_curve1(1,3),'--ro');
% plot3(left_curve1(:,1),left_curve1(:,2),left_curve1(:,3),'--r*'); grid on
fclose(fidin);
fclose(fidout);
%% plot the orientation and r
data_folder = 'tsd_data_bat/not-my-problem/';  % LOCATION OF C3D FILES
fidin = fopen(strcat(data_folder, '9-not-my-problem-1.tsd'));
fidout = fopen('mkmatlab.txt', 'w');
i = 1;
while ~feof(fidin)
    tline = fgetl(fidin);
    tline = str2num(tline);
    fprintf(fidout, '%s\n', tline);
    mk(i, :) = tline;
    i = i + 1;
    continue
end
x = mk(:, 1) * 10e3; y = mk(:, 2) * 10e3; z = mk(:, 3) * 10e3;
x1 = mk(:, 12) * 10e3; y1 = mk(:, 13) * 10e3; z1 = mk(:, 14) * 10e3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% moving average filter

% x=movave(x,5);y=movave(y,5);z=movave(z,5);
% x1=movave(x1,5);y1=movave(y1,5);z1=movave(z1,5);

%%%%%%%%%%%%%%%%%%%%%%%%%% another method of kalman filter
ss = 6; % state size
os = 3; % observation size
F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
H = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0];
Q = 0.05 * eye(ss);
R = 1 * eye(os);
initx = [x(1) y(1) z(1) 0.05 0.05 0.05]';
initV = 1 * eye(ss);
[marker_smooth, ~, ~, ~] = kalman_smoother([x y z]', F, H, Q, R, initx, initV);
x = marker_smooth(1, :)';
y = marker_smooth(2, :)';
z = marker_smooth(3, :)';

initx = [x1(1) y1(1) z1(1) 0.05 0.05 0.05]';
initV = 1 * eye(ss);
[marker_smooth, ~, ~, ~] = kalman_smoother([x1 y1 z1]', F, H, Q, R, initx, initV);
x1 = marker_smooth(1, :)';
y1 = marker_smooth(2, :)';
z1 = marker_smooth(3, :)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
angle = 0 * pi / 180;
right_curve2 = [x y z];
left_curve2 = [x1 y1 z1];
% right_curve2 = interpolation(right_curve2,2*size(right_curve2,1),0);
% left_curve2 = interpolation(left_curve2,2*size(left_curve2,1),0);
samples = size(right_curve2, 1);
rotatematrix = [cos(angle) -sin(angle) 0;
                sin(angle) cos(angle)  0;
                0       0        1];
translation_matrix = [1000, 3500, 000];
translation_matrix = ones(samples, 1) * translation_matrix;
translation_matrix = translation_matrix';
right_curve2 = rotatematrix * right_curve2' + translation_matrix;
left_curve2 = rotatematrix * left_curve2' + translation_matrix;
right_curve2 = right_curve2';
left_curve2 = left_curve2';
[orientation2, r2] = gene_relative_descrip(right_curve2, left_curve2);

% orientation2 = [sin(orientation2(:,1)).*cos(orientation2(:,2))...
%      sin(orientation2(:,1)).*sin(orientation2(:,2)) cos(orientation2(:,1))];

figure(1);
Right = plot3(right_curve2(:, 1), right_curve2(:, 2), right_curve2(:, 3), '.r-'); hold on; grid on;

Left = plot3(left_curve2(:, 1), left_curve2(:, 2), left_curve2(:, 3), 'xb-'); hold on;
axis image, view(3), legend([Right Left], {'Right Hand', 'Left Hand'});
save variable2 orientation2 r2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot the curve
% figure(2);
% plot3(right_curve2(1,1),right_curve2(1,2),right_curve2(1,3),'--ro');
% hold on;
% subplot(2,1,1),plot3(right_curve2(:,1),right_curve2(:,2),right_curve2(:,3),'--b*');grid on;
% hold on;
% subplot(2,1,2),plot3(left_curve2(1,1),left_curve2(1,2),left_curve2(1,3),'--ro');
% plot3(left_curve2(:,1),left_curve2(:,2),left_curve2(:,3),'--r*'); grid on;
fclose(fidin);
fclose(fidout);
%% plot the orientation and r
data_folder = 'tsd_data_bat/cold/';  % LOCATION OF C3D FILES
fidin = fopen(strcat(data_folder, '7-cold-1.tsd'));
fidout = fopen('mkmatlab.txt', 'w');
i = 1;
while ~feof(fidin)
    tline = fgetl(fidin);
    tline = str2num(tline);
    fprintf(fidout, '%s\n', tline);
    mk(i, :) = tline;
    i = i + 1;
    continue
end
x = mk(:, 1) * 10e3; y = mk(:, 2) * 10e3; z = mk(:, 3) * 10e3;
x1 = mk(:, 12) * 10e3; y1 = mk(:, 13) * 10e3; z1 = mk(:, 14) * 10e3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% moving average filter

% x=movave(x,5);y=movave(y,5);z=movave(z,5);
% x1=movave(x1,5);y1=movave(y1,5);z1=movave(z1,5);

%%%%%%%%%%%%%%%%%%%%%%%%%% another method of kalman filter
ss = 6; % state size
os = 3; % observation size
F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
H = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0];
Q = 0.05 * eye(ss);
R = 1 * eye(os);
initx = [x(1) y(1) z(1) 0.05 0.05 0.05]';
initV = 1 * eye(ss);
[marker_smooth, ~, ~, ~] = kalman_smoother([x y z]', F, H, Q, R, initx, initV);
x = marker_smooth(1, :)';
y = marker_smooth(2, :)';
z = marker_smooth(3, :)';

initx = [x1(1) y1(1) z1(1) 0.05 0.05 0.05]';
initV = 1 * eye(ss);
[marker_smooth, ~, ~, loglik] = kalman_smoother([x1 y1 z1]', F, H, Q, R, initx, initV);
x1 = marker_smooth(1, :)';
y1 = marker_smooth(2, :)';
z1 = marker_smooth(3, :)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

right_curve3 = [x y z];
left_curve3 = [x1 y1 z1];
%% db4 wavelet filter
% right_curve3=wav_filter(right_curve3);
% left_curve3=wav_filter(left_curve3);

[orientation3, r3] = gene_relative_descrip(right_curve3, left_curve3);
save variable3 orientation3 r3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot the curve
figure(3);
plot3(right_curve3(1, 1), right_curve3(1, 2), right_curve3(1, 3), '--ro');
hold on;
subplot(2, 1, 1), plot3(right_curve3(:, 1), right_curve3(:, 2), right_curve3(:, 3), '--b*'); grid on;
hold on;
subplot(2, 1, 2), plot3(left_curve3(1, 1), left_curve3(1, 2), left_curve3(1, 3), '--ro');
plot3(left_curve3(:, 1), left_curve3(:, 2), left_curve3(:, 3), '--r*'); grid on;
%% plot the orientation and r
% figure(4);
% subplot(3,1,1), plot(orientation1);subplot(3,1,2),plot(orientation2);subplot(3,1,3),plot(orientation3);
% figure(5);
% subplot(3,1,1), plot(r1);subplot(3,1,2),plot(r2);subplot(3,1,3),plot(r3);
figure(4);
subplot(2, 1, 1), orienfig1 = plot(orientation1(:, 1), '.r-'); hold on; orienfig2 = plot(orientation1(:, 2), 'xb-');
axis xy, legend([orienfig1 orienfig2], {'\theta_1^*', '\phi_1^*'});
subplot(2, 1, 2), orienfig1 = plot(orientation2(:, 1), '.r-'); hold on; orienfig2 = plot(orientation2(:, 2), 'xb-');
axis xy, legend([orienfig1 orienfig2], {'\theta_2^*', '\phi_2^*'});
figure(5);
subplot(2, 1, 1), rfig1 = plot(r1, '.r-');
axis xy, legend([rfig1], {'r1*'});
subplot(2, 1, 2), rfig2 = plot(r2, 'xb-');
axis xy, legend([rfig2], {'r2*'});
fclose('all');
