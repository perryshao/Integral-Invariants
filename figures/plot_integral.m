function plot_integral(trajectory)
length = size(trajectory, 1);
% radius = 0.08; % for msr
radius = 0.05; % for hdm
% radius = 0.3; % for multiscale
% radius = 0.08; % for mhad
% radius = 0.04; % for analytic curve
% noise_level = [0.01 0.02 0.03]; % for analytic curve
noise_level = [0.05 0.1 0.2]; % for hdm
% noise_level = [0.01 0.02 0.04];% for msr
% noise_level = [0.08 0.1 0.15];% for mhad
width = 8 / sqrt(2);
%% original trajectory

integral_original = integral_invariant(trajectory, width, radius);
% integral_original = integral_invariant_kn(trajectory,8,5);
differential_original = descriptor_comp(trajectory);
%% noise level 1
% [Y,NOISE] = noisegen(trajectory,noise_level(1));
mindim = min([max(trajectory(:, 1)) - min(trajectory(:, 1))...
              max(trajectory(:, 2)) - min(trajectory(:, 2))...
              max(trajectory(:, 3)) - min(trajectory(:, 3))]);
maxdim = max([max(trajectory(:, 1)) - min(trajectory(:, 1))...
              max(trajectory(:, 2)) - min(trajectory(:, 2))...
              max(trajectory(:, 3)) - min(trajectory(:, 3))]);
if mindim < 1
    signal_p = mindim^2;
else
    signal_p = sqrt(mindim);
end
Y1(:, 1) = trajectory(:, 1) + (noise_level(1) * randn(1, size(trajectory, 1)) * signal_p)';
Y1(:, 2) = trajectory(:, 2) + (noise_level(1) * randn(1, size(trajectory, 1)) * signal_p)';
Y1(:, 3) = trajectory(:, 3) + (noise_level(1) * randn(1, size(trajectory, 1)) * signal_p)';

% Y = awgn(trajectory,45);

% Y = filter_kalman(Y1,1);
% integral_noise1 = integral_invariant(Y1,width,radius);% for all dataset
% differential_noise1 = descriptor_comp(Y1);

mindim = min([max(Y1(:, 1)) - min(Y1(:, 1))...
              max(Y1(:, 2)) - min(Y1(:, 2))...
              max(Y1(:, 3)) - min(Y1(:, 3))]);
maxdim = max([max(Y1(:, 1)) - min(Y1(:, 1))...
              max(Y1(:, 2)) - min(Y1(:, 2))...
              max(Y1(:, 3)) - min(Y1(:, 3))]);

noise_f = mindim / maxdim; %% key factor that affect the results of estimation below
integral_noise1 = integral_invariant(Y1, noise_level(1) * 1000 * noise_f / 2 * sqrt(2) + width, radius); % for all dataset
% integral_noise1 = integral_invariant_kn(Y1,noise_level(1)*1000*noise_f/2*sqrt(2)+width,15);
% integral_noise1 = integral_invariant(Y1,8,radius);% for all dataset
differential_noise1 = descriptor_comp(Y1);
%% plot the first figure
figure(1);
subplot(2, 2, 1), plot(integral_original(2:end - 2, 1), '.-k');
axis([0 length 0 1]); title('Integral Invariat on Osculating Plane');
subplot(2, 2, 3), plot(integral_original(2:end - 2, 2), '.-k');
axis([0 length 0 1]); title('Integral Invariant on Rectifying Plane');

subplot(2, 2, 2), plot(differential_original(2:end - 2, 1), '.-k');
xlim([0 length]);
% axis([0 length 0 1]);
title('Curvature');
subplot(2, 2, 4), plot(differential_original(2:end - 2, 3), '.-k');
xlim([0 length]);
% axis([0 length -0.5 0.5]);
title('Torsion');

figure(2);
subplot(2, 2, 1), plot(integral_noise1(2:end - 2, 1), '.-k');
axis([0 length 0 1]); title('Integral Invariat on Osculating Plane');
subplot(2, 2, 3), plot(integral_noise1(2:end - 2, 2), '.-k');
axis([0 length 0 1]); title('Integral Invariant on Rectifying Plane');

subplot(2, 2, 2), plot(differential_noise1(2:end - 2, 1), '.-k');
xlim([0 length]);
% axis([0 length 0 1]);
title('Curvature');
subplot(2, 2, 4), plot(differential_noise1(2:end - 2, 3), '.-k');
xlim([0 length]);
% axis([0 length -0.5 0.5]);
title('Torsion');
%%  noise level 2
% [Y,NOISE] = noisegen(trajectory,noise_level(1));
mindim = min([max(trajectory(:, 1)) - min(trajectory(:, 1))...
              max(trajectory(:, 2)) - min(trajectory(:, 2))...
              max(trajectory(:, 3)) - min(trajectory(:, 3))]);
%              noise_inten = level*(size(marker_xyz,1)/500).^2;
if mindim < 1
    signal_p = mindim^2;
else
    signal_p = sqrt(mindim);
end
Y2(:, 1) = trajectory(:, 1) + (noise_level(2) * randn(1, size(trajectory, 1)) * signal_p)';
Y2(:, 2) = trajectory(:, 2) + (noise_level(2) * randn(1, size(trajectory, 1)) * signal_p)';
Y2(:, 3) = trajectory(:, 3) + (noise_level(2) * randn(1, size(trajectory, 1)) * signal_p)';

% Y = awgn(trajectory,45);
% Y=filter_kalman(Y,2);

% Y = filter_kalman(Y2,1);
% integral_noise2 = integral_invariant(Y2,width,radius);% for all data
% differential_noise2 = descriptor_comp(Y2);

mindim = min([max(Y2(:, 1)) - min(Y2(:, 1))...
              max(Y2(:, 2)) - min(Y2(:, 2))...
              max(Y2(:, 3)) - min(Y2(:, 3))]);
maxdim = max([max(Y2(:, 1)) - min(Y2(:, 1))...
              max(Y2(:, 2)) - min(Y2(:, 2))...
              max(Y2(:, 3)) - min(Y2(:, 3))]);
noise_f = mindim / maxdim;
integral_noise2 = integral_invariant(Y2, noise_level(2) * 1000 * noise_f / 2 * sqrt(2) + width, radius); % for all dataset
% integral_noise2 = integral_invariant_kn(Y2,noise_level(2)*1000*noise_f/2*sqrt(2)+width,15);
% integral_noise2 = integral_invariant(Y2,8,radius);% for all dataset
differential_noise2 = descriptor_comp(Y2);

figure(3);
subplot(2, 2, 1), plot(integral_noise2(2:end - 2, 1), '.-k');
axis([0 length 0 1]); title('Integral Invariat on osculating plane');
subplot(2, 2, 3), plot(integral_noise2(2:end - 2, 2), '.-k');
axis([0 length 0 1]); title('Integral Invariant on rectifying plane');

subplot(2, 2, 2), plot(differential_noise2(2:end - 2, 1), '.-k');
xlim([0 length]);
% axis([0 length 0 1]);
title('Curvature');
subplot(2, 2, 4), plot(differential_noise2(2:end - 2, 3), '.-k');
xlim([0 length]);
% axis([0 length -0.5 0.5]);
title('Torsion');
%% third noise version
% [Y,NOISE] = noisegen(trajectory,noise_level(1));
mindim = min([max(trajectory(:, 1)) - min(trajectory(:, 1))...
              max(trajectory(:, 2)) - min(trajectory(:, 2))...
              max(trajectory(:, 3)) - min(trajectory(:, 3))]);
%              noise_inten = level*(size(marker_xyz,1)/500).^2;
if mindim < 1
    signal_p = mindim^2;
else
    signal_p = sqrt(mindim);
end
Y3(:, 1) = trajectory(:, 1) + (noise_level(2) * randn(1, size(trajectory, 1)) * signal_p)';
Y3(:, 2) = trajectory(:, 2) + (noise_level(2) * randn(1, size(trajectory, 1)) * signal_p)';
Y3(:, 3) = trajectory(:, 3) + (noise_level(2) * randn(1, size(trajectory, 1)) * signal_p)';

% Y = awgn(trajectory,45);
% Y=filter_kalman(Y,2);

% Y = filter_kalman(Y3,1);
% integral_noise3 = integral_invariant(Y3,width,radius);% for all data
% differential_noise3 = descriptor_comp(Y3);
% integral_noise3 = integral_invariant(Y3,width,radius);% for all data

mindim = min([max(Y3(:, 1)) - min(Y3(:, 1))...
              max(Y3(:, 2)) - min(Y3(:, 2))...
              max(Y3(:, 3)) - min(Y3(:, 3))]);
maxdim = max([max(Y3(:, 1)) - min(Y3(:, 1))...
              max(Y3(:, 2)) - min(Y3(:, 2))...
              max(Y3(:, 3)) - min(Y3(:, 3))]);
noise_f = mindim / maxdim;

integral_noise3 = integral_invariant(Y3, noise_level(3) * 1000 * noise_f / 2 * sqrt(2) + width, radius);
% integral_noise3 = integral_invariant_kn(Y3,noise_level(3)*1000*noise_f/2*sqrt(2)+width,15);
% integral_noise3 = integral_invariant(Y3,8,radius);
differential_noise3 = descriptor_comp(Y3);

figure(4);
subplot(2, 2, 1), plot(integral_noise3(2:end - 2, 1), '.-k');
axis([0 length 0 1]); title('Integral Invariat on osculating plane');
subplot(2, 2, 3), plot(integral_noise3(2:end - 2, 2), '.-k');
axis([0 length 0 1]); title('Integral Invariant on rectifying plane');

subplot(2, 2, 2), plot(differential_noise3(2:end - 2, 1), '.-k');
xlim([0 length]);
% axis([0 length 0 1]);
title('Curvature');
subplot(2, 2, 4), plot(differential_noise3(2:end - 2, 3), '.-k');
xlim([0 length]);
% axis([0 length -0.5 0.5]);
title('Torsion');

figure(5);
plot3d(trajectory); view(65, 20);
figure(6);
plot3d(Y1); view(65, 20);
figure(7);
plot3d(Y2); view(65, 20);
figure(8);
plot3d(Y3); view(65, 20);
