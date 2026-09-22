function matchingScore = run_matching(aTrajectory, bTrajectory,descriptorId)
%% parameter definition
%  Input:
%  aTrajectory -- a source 3D motion trajectory with a 3D sequence of points
%  bTrajectory -- a target 3D motion trajectory with a 3D sequence of points
%  descriptorId -- indicate what type of descriptor is used to measure the similarity
%  Output:
%  matchingScore -- how similar two trajectories are


aTrajectory = double(aTrajectory);
bTrajectory = double(bTrajectory);
fprintf ('using the %dth descriptor...\n',descriptorId);
a_descriptor = cal_descriptors(aTrajectory, descriptorId);
b_descriptor = cal_descriptors(bTrajectory, descriptorId);
[dtw_distance, ~, ~,path]=dtw_adj_matching(a_descriptor,b_descriptor,450,descriptorId);

% plot the dtw illustration
% % aTrajectory = aTrajectory*0.1;
% bTrajectory(:,3) = bTrajectory(:,3)+0.6;
% bTrajectory = bTrajectory*10;
% plot3d(aTrajectory,'k');hold on, plot3d(bTrajectory,'b'); hold on;
% for i = 1:size(path,1)
%     plot3([aTrajectory(path(i,1),1) bTrajectory(path(i,2),1)],...
%          [aTrajectory(path(i,1),2) bTrajectory(path(i,2),2)],...
%          [aTrajectory(path(i,1),3) bTrajectory(path(i,2),3)]), hold on;
% end

matchingScore = dtw_distance;


