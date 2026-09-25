%% the script to run trajectory matching
descriptorId = 2; % 4 for maii， 2 for di
descriptorId = 3; % 3 for aii
descriptorId = 10; % 4 for maii， 2 for di, 10 for rrv
load('OptiTrackMotivePhase_1.mat');
load('OptiTrackMotivePhase_2.mat');
load('OptiTrackMotivePhase_3.mat');
load('OptiTrackMotivePhase_4.mat');
load('OptiTrackUnityPhase_1.mat');
load('OptiTrackUnityPhase_2.mat');
load('OptiTrackUnityPhase_3.mat');
load('OptiTrackUnityPhase_4.mat');
OptiTrackMotivePhase_1_Gtraj = cell2mat(OptiTrackMotivePhase_1(3:end, end - 2:end)); % only XYZ, no time instance
OptiTrackMotivePhase_1_Ttraj = cell2mat(OptiTrackMotivePhase_1(3:end, 2));
OptiTrackMotivePhase_2_Gtraj = cell2mat(OptiTrackMotivePhase_2(:, end - 2:end));
OptiTrackMotivePhase_2_Ttraj = cell2mat(OptiTrackMotivePhase_2(:, 2));
OptiTrackMotivePhase_3_Gtraj = cell2mat(OptiTrackMotivePhase_3(:, end - 2:end));
OptiTrackMotivePhase_3_Ttraj = cell2mat(OptiTrackMotivePhase_3(:, 2));
OptiTrackMotivePhase_4_Gtraj = cell2mat(OptiTrackMotivePhase_4(:, end - 2:end));
OptiTrackMotivePhase_4_Ttraj = cell2mat(OptiTrackMotivePhase_4(:, 2));

OptiTrackUnityPhase_1_Gtraj = cell2mat(OptiTrackUnityPhase_1(2:end, 1:3)); % only XYZ, no time instance
OptiTrackUnityPhase_1_Ttraj = cell2mat(OptiTrackUnityPhase_1(2:end, end));
OptiTrackUnityPhase_2_Gtraj = cell2mat(OptiTrackUnityPhase_2(:, 1:3));
OptiTrackUnityPhase_2_Ttraj = cell2mat(OptiTrackUnityPhase_2(:, end));
OptiTrackUnityPhase_3_Gtraj = cell2mat(OptiTrackUnityPhase_3(:, 1:3));
OptiTrackUnityPhase_3_Ttraj = cell2mat(OptiTrackUnityPhase_3(:, end));
OptiTrackUnityPhase_4_Gtraj = cell2mat(OptiTrackUnityPhase_4(:, 1:3));
OptiTrackUnityPhase_4_Ttraj = cell2mat(OptiTrackUnityPhase_4(:, end));

OptiTrackMotivePhase_1 = [OptiTrackMotivePhase_1_Gtraj OptiTrackMotivePhase_1_Ttraj];
OptiTrackMotivePhase_2 = [OptiTrackMotivePhase_2_Gtraj OptiTrackMotivePhase_2_Ttraj];
OptiTrackMotivePhase_3 = [OptiTrackMotivePhase_3_Gtraj OptiTrackMotivePhase_3_Ttraj];
OptiTrackMotivePhase_4 = [OptiTrackMotivePhase_4_Gtraj OptiTrackMotivePhase_4_Ttraj];
OptiTrackUnityPhase_1 = [OptiTrackUnityPhase_1_Gtraj OptiTrackUnityPhase_1_Ttraj];
OptiTrackUnityPhase_2 = [OptiTrackUnityPhase_2_Gtraj OptiTrackUnityPhase_2_Ttraj];
OptiTrackUnityPhase_3 = [OptiTrackUnityPhase_3_Gtraj OptiTrackUnityPhase_3_Ttraj];
OptiTrackUnityPhase_4 = [OptiTrackUnityPhase_4_Gtraj OptiTrackUnityPhase_4_Ttraj];

matchingScore1 = run_matching(OptiTrackMotivePhase_1, OptiTrackMotivePhase_2, descriptorId);
matchingScore2 = run_matching(OptiTrackMotivePhase_2, OptiTrackMotivePhase_3, descriptorId);
matchingScore3 = run_matching(OptiTrackMotivePhase_3, OptiTrackMotivePhase_4, descriptorId);

matchingScore4 = run_matching(OptiTrackUnityPhase_1, OptiTrackUnityPhase_2, descriptorId);
matchingScore5 = run_matching(OptiTrackUnityPhase_2, OptiTrackUnityPhase_3, descriptorId);
matchingScore6 = run_matching(OptiTrackUnityPhase_3, OptiTrackUnityPhase_4, descriptorId);

matchingScore7 = run_matching(OptiTrackMotivePhase_1, OptiTrackUnityPhase_1, descriptorId);
matchingScore8 = run_matching(OptiTrackMotivePhase_2, OptiTrackUnityPhase_2, descriptorId);
matchingScore9 = run_matching(OptiTrackMotivePhase_3, OptiTrackUnityPhase_3, descriptorId);
matchingScore10 = run_matching(OptiTrackMotivePhase_4, OptiTrackUnityPhase_4, descriptorId);

% path_value = zeros(size(path,1),1);
% for m = 1:size(path,1)
%     path_value(m,1) = d(path(m,1),path(m,2));
% end
