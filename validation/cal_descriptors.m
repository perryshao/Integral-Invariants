function descriptor = cal_descriptors(trajectory, descriptorId)
%% parameter definition
%  Input:
%  aTrajectory -- a 3D motion trajectory with a 3D sequence of points
%  descriptorId -- indicate what type of descriptor is used to measure the similarity
%  Output:
%  descriptor -- the descriptor of the trajectory

% Parameters for computing shape context
mean_dist_global = []; % use [] to estimate scale from the data
nbins_theta = 18;
nbins_alpha = 9;
nbins_r = 10;
ndum1 = 0;
eps_dum = 0.15;
r_inner = 0.1;
r_outer = 2.5;

switch descriptorId
    case 1
        fd = fft(trajectory);
        fd = fd ./ repmat(abs(fd(2, :)), size(fd, 1), 1);
        descriptor = fd(2:end, :);
        %                 marker_des = abs(fd(2:end,:));
    case 2
        descriptor = descriptor_comp(trajectory);
    case 3
        %                 marker_des = integral_invariant(marker_xyz,8,0.05);
        %         descriptor = integral_invariant_kn(trajectory,8,20);
        %         descriptor = integral_invariant_kn(trajectory,8,5);
        descriptor = integral_invariant_kn(trajectory, 8, 20);
        descriptor = 0.5 - descriptor;
        %                 marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
        %                              marker_des(:,2) [0;diff(marker_des(:,2),1,1)]];
    case 4
        %         descriptor = integral_invariant_ms(trajectory,8,0.3);
        %         descriptor = integral_invariant_mkn(trajectory,8,35);
        descriptor = integral_invariant_mkn(trajectory, 10, 50);

        descriptor = 0.5 - descriptor;
    case 5
        %                 marker_des = integral_invariant_dist(marker_xyz,20);
        descriptor = integral_invariant_dist(trajectory, 20);
    case 6
        descriptor = integral_invariant_dist_mkn(trajectory, 60);
    case 8
        nsamp1 = size(trajectory, 1);
        % outlies on each iteration
        out_vec_1 = zeros(1, nsamp1 - 4); % beginning and ending elements are excluded
        % Frenet Frames
        FrenetVector = Estimate_Frenet(trajectory, 8);
        FVector = FrenetVector(3:end - 2, :);
        % compute shape contexts for (transformed) model
        Bsamp = trajectory(3:end - 2, :);
        [BH_theta, BH_alpha, mean_dist_1] = sc3d_compute(Bsamp', FVector', mean_dist_global, nbins_theta, nbins_alpha, nbins_r, r_inner, r_outer, out_vec_1);
        descriptor = cat(2, BH_theta, BH_alpha);
    case 9
        descriptor = Moment_Invariant(trajectory);
    case 10 % RRV descriptors based on local frames\
        Gtrajectory = trajectory(:, 1:3); % geometric shape trajectory
        Ttrajectory = trajectory(:, end); % geometric shape trajectory
        %         [Gtrajectory,Ttrajectory] = remove_staTime(Gtrajectory,Ttrajectory);
        FrenetVector = Estimate_Frenet(Gtrajectory, 10);
        FVector = FrenetVector(3:end - 2, :);
        Gtrajectory = trajectory(3:end - 2, 1:3);
        Ttrajectory = trajectory(3:end - 2, end);
        %         descriptor = RRVdescriptor_BasedonFrames(FrenetVector,trajectory);
        descriptor = FrameRRV_times(FVector, Gtrajectory, Ttrajectory);
    otherwise
        error('IID:unsupportedDescriptorFlag', 'Unsupported descriptorId: %d', descriptorId);
end
