%% the script to run trajectory matching
descriptorId = 2; % 4 for maii， 2 for di
% descriptorId = 3;% 4 for maii， 2 for di, 3 for aii
% descriptorId = 10;% 4 for maii， 2 for di, 10 for rrv
load('OptitrackMotive.mat');
load('OptitrackUnity.mat')
load('trakSTARCubes.mat')
OptitrackMotive = remove_NaNpoint(OptitrackMotive);
OptiMotive_Gtraj = cell2mat(OptitrackMotive(2:end, end - 2:end));
OptiMotive_Ttraj =  cell2mat(OptitrackMotive(2:end, 2));
OptitrackUnity = remove_NaNpoint(OptitrackUnity);
OptiUnity_Gtraj = cell2mat(OptitrackUnity(2:end, 1:3));
OptiUnity_Ttraj = cell2mat(OptitrackUnity(2:end, 4));
trakSTARCubes = remove_NaNpoint(trakSTARCubes);
trakSTAR_Gtraj = cell2mat(trakSTARCubes(2:end, 1:3));
trakSTAR_Ttraj = cell2mat(trakSTARCubes(2:end, 4));

% OptiMotive_traj = [OptiMotive_Gtraj OptiMotive_Ttraj];
% OptiUnity_traj = [OptiUnity_Gtraj OptiUnity_Ttraj];
% trakSTAR_traj = [trakSTAR_Gtraj trakSTAR_Ttraj];

% OptiUnity_length = size(OptiUnity_traj,1);
% sampling_indx = 1:6:OptiUnity_length;
% OptiUnity_traj = OptiUnity_traj(sampling_indx,:);
matchingScore1 = run_matching(OptiMotive_Gtraj, OptiUnity_Gtraj, descriptorId);
matchingScore2 = run_matching(OptiMotive_Gtraj, trakSTAR_Gtraj, descriptorId);
matchingScore3 = run_matching(trakSTAR_Gtraj, OptiUnity_Gtraj, descriptorId);

% path_value = zeros(size(path,1),1);
% for m = 1:size(path,1)
%     path_value(m,1) = d(path(m,1),path(m,2));
% end
