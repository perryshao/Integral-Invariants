function trajectory = filter_kalman(trajectory, level)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Kalman Filter

ss = 6; % state size
os = 3; % observation size
F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
H = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0];
Q = 0.1 * eye(ss);
R = level * eye(os);
initx = [trajectory(1, 1) trajectory(1, 2) trajectory(1, 3) 0.1 0.1 0.1]';
initV = 1 * eye(ss);
[marker_smooth, ~, ~, loglik] = kalman_smoother(trajectory', F, H, Q, R, initx, initV);
loglik;

trajectory = marker_smooth(1:3, :)';
