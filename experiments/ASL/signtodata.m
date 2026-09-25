clearvars;
mk = load('write0.sign');
lenth = size(mk);
rowsize = lenth(1);
xyz = mk(:, 1:3) * 10e3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Kalman Filter

ss = 6; % state size
os = 3; % observation size
F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
H = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0];
Q = 0.001 * eye(ss);
R = 0.005 * eye(os);
initx = [xyz(1, 1) xyz(1, 2) xyz(1, 3) 0.001 0.001 0.001]';
initV = 1 * eye(ss);
[xsmooth1, Vsmooth1, VVsmooth, loglik] = kalman_smoother(xyz', F, H, Q, R, initx, initV);
loglik

xyz(:, 1) = xsmooth1(1, :);
xyz(:, 2) = xsmooth1(2, :);
xyz(:, 3) = xsmooth1(3, :);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   wave filter
% xyz = wav_filter(xyz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% moving average filter
% xyz(:,1)=movave(xyz(:,1),7);xyz(:,2)=movave(xyz(:,2),7);xyz(:,3)=movave(xyz(:,3),7);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
plot3(xyz(1, 1), xyz(1, 2), xyz(1, 3), '--ro', xyz(1:end, 1), xyz(1:end, 2), xyz(1:end, 3), '--b*'); grid on;
