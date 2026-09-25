function [distance_matrix_interg, recog_ratio_interg, distance_table_interg] = trajectory_matching(marker, level, descrip_flag, occlu_ratio)
% copyfile('mat/*.*','../HDM05EvaluatingCode/','f');
fprintf(1, 'loading  data...\n');
fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end
fileprefix = 'samples.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end
samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2));
end
trainGID = grp2idx(TRAJDB(1, :)');
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2));
end
testGID = grp2idx(TRAJSAMPLES(1, :)');
train_num = length(trainGID);
test_num = length(testGID);
ClusterRawData = cell(1, train_num + test_num);
for i = 1:train_num
    ClusterRawData{1, i} = TRAJDB{2, i};
end
test_num = length(testGID);
for i = 1:test_num
    ClusterRawData{1, i + train_num} = TRAJSAMPLES{2, i};
end
ClusterID = [trainGID; testGID];

if occlu_ratio == 0
    occlu_flag = 0;
else
    occlu_flag = 1;
end

% Parameters for computing shape context
mean_dist_global = []; % use [] to estimate scale from the data
nbins_theta = 18;
nbins_alpha = 9;
nbins_r = 10;
ndum1 = 0;
eps_dum = 0.15;
r_inner = 0.1;
r_outer = 2.5;

EXPERIMENT_NUM = 30;
for experiment_num = 1:EXPERIMENT_NUM

    % select trajectories randomly
    i = 1;
    original_trajectory = cell(1, 16);
    noise_trajectory = cell(1, 16);
    while i < 17,
        indx = find(ClusterID == i);
        indx = indx((randperm(length(indx), 1)));
        original_trajectory{i} = ClusterRawData{1, indx};
        i = i + 1;
    end
    trainGID = (1:16)'; testGID = (1:16)';

    % load TRAJDB;
    theta_x = 30; tx = 200; % in degree
    theta_y = 0; ty = 100;
    theta_z = 45; tz = 0;
    s = 0.5; % scale factor
    for i = 1:16
        marker_xyz = original_trajectory{i};

        %         percent = rand;
        %         if percent <0.5
        %             marker_xyz = interpolation(marker_xyz,fix(size(marker_xyz,1)*(1+percent)),0);
        %         else
        %             marker_xyz = anti_interpolation(marker_xyz,fix(size(marker_xyz,1)*percent));
        %         end

        mindim = min([max(marker_xyz(:, 1)) - min(marker_xyz(:, 1))...
                      max(marker_xyz(:, 2)) - min(marker_xyz(:, 2))...
                      max(marker_xyz(:, 3)) - min(marker_xyz(:, 3))]);
        maxdim = max([max(marker_xyz(:, 1)) - min(marker_xyz(:, 1))...
                      max(marker_xyz(:, 2)) - min(marker_xyz(:, 2))...
                      max(marker_xyz(:, 3)) - min(marker_xyz(:, 3))]);
        noise_f(i) = sqrt(mindim) / sqrt(maxdim);

        marker_xyz(:, 1) = marker_xyz(:, 1) + (level * randn(1, size(marker_xyz, 1)) * sqrt(mindim))';
        marker_xyz(:, 2) = marker_xyz(:, 2) + (level * randn(1, size(marker_xyz, 1)) * sqrt(mindim))';
        marker_xyz(:, 3) = marker_xyz(:, 3) + (level * randn(1, size(marker_xyz, 1)) * sqrt(mindim))';

        %         Noise_tens = randn(size(marker_xyz,1),size(marker_xyz,2));
        %         sigma=(10^(-SNR/20))*(norm(marker_xyz,'fro')/norm(Noise_tens,'fro'));
        %         marker_xyz = marker_xyz + sigma*Noise_tens;

        marker_xyz(:, end + 1) = 1; % qici matrix
        marker_xyz = marker_xyz';
        marker_xyz = makehgtform('xrotate', (theta_x * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('yrotate', (theta_y * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('zrotate', (theta_z * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('translate', tx, ty, tz) * marker_xyz;
        marker_xyz = makehgtform('scale', s) * marker_xyz;
        marker_xyz = marker_xyz';
        marker_xyz(:, end) = [];

        noise_trajectory{i} = marker_xyz;
        % cut the trajectory with occlu_ratio occlusion
        if occlu_flag == 1
            length_trajectory = size(noise_trajectory{i}, 1);
            occlu_indx = fix(length_trajectory * rand * (1 - occlu_ratio)) + 1;
            noise_trajectory{i}(occlu_indx:occlu_indx + fix(length_trajectory * occlu_ratio), :) = NaN;
        end

    end

    samples = length(original_trajectory);
    TRAJDB_DES = cell(1, samples);
    for i = 1:samples
        marker_xyz = double(original_trajectory{i});
        fprintf ('%d of %d %dth descriptor...\n', i, samples, descrip_flag);
        switch descrip_flag
            case 1
                fd = fft(marker_xyz);
                fd = fd ./ repmat(abs(fd(2, :)), size(fd, 1), 1);
                marker_des = fd(2:end, :);
                %                 marker_des = abs(fd(2:end,:));
            case 2
                marker_des = descriptor_comp(marker_xyz);
            case 3
                %                 marker_des = integral_invariant(marker_xyz,8,0.05);
                marker_des = integral_invariant_kn(marker_xyz, 8, 20);
                %                 marker_des = integral_invariant_kn(marker_xyz,8,5);
                marker_des = 0.5 - marker_des;
                %                 marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
                %                              marker_des(:,2) [0;diff(marker_des(:,2),1,1)]];
            case 4
                marker_des = integral_invariant_ms(marker_xyz, 8, 0.3);
                %                 marker_des = integral_invariant_mkn(marker_xyz,8,35);
                marker_des = 0.5 - marker_des;
            case 5
                %                 marker_des = integral_invariant_dist(marker_xyz,20);
                marker_des = integral_invariant_dist(marker_xyz, 20);
            case 6
                marker_des = integral_invariant_dist_mkn(marker_xyz, 60);
            case 8
                nsamp1 = size(marker_xyz, 1);
                % outliers on each iteration
                out_vec_1 = zeros(1, nsamp1 - 4); % beginning and ending elements are excluded
                % Frenet Frames
                FrenetVector = Estimate_Frenet(marker_xyz, 8);
                FVector = FrenetVector(3:end - 2, :);
                % compute shape contexts for (transformed) model
                Bsamp = marker_xyz(3:end - 2, :);
                [BH_theta, BH_alpha, mean_dist_1] = sc3d_compute(Bsamp', FVector', mean_dist_global, nbins_theta, nbins_alpha, nbins_r, r_inner, r_outer, out_vec_1);
                marker_des = cat(2, BH_theta, BH_alpha);
            case 9
                marker_des = Moment_Invariant(marker_xyz);
            otherwise
                error('IID:unsupportedDescriptorFlag', 'Unsupported descrip_flag: %d', descrip_flag);
        end

        TRAJDB_DES{1, i} = marker_des;
    end

    samples = length(noise_trajectory);
    TRAJSAMPLES_DES = cell(1, samples);
    for i = 1:samples
        marker_xyz = double(noise_trajectory{i});
        fprintf ('%d of %d %dth samples descriptor...\n', i, samples, descrip_flag);
        switch descrip_flag
            case 1
                marker_xyz = remove_stapoint(marker_xyz);
                fd = fft(marker_xyz);
                fd = fd ./ repmat(abs(fd(2, :)), size(fd, 1), 1);
                marker_des = fd(2:end, :);
                %                 marker_des = abs(fd(2:end,:));
            case 2
                marker_des = descriptor_comp(marker_xyz);
                [marker_des, ~] = remove_stapoint(marker_des);
            case 3
                %                 marker_des = integral_invariant(marker_xyz,20,0.05);
                marker_des = integral_invariant_kn(marker_xyz, 20, 20);
                %                 marker_des = integral_invariant_kn(marker_xyz,8,5);
                marker_des = 0.5 - marker_des;
                %                 marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
                %                              marker_des(:,2) [0; diff(marker_des(:,2),1,1)]];
            case 4
                marker_des = integral_invariant_ms(marker_xyz, 20, 0.3);
                %                 marker_des = integral_invariant_mkn(marker_xyz,20,35);
                marker_des = 0.5 - marker_des;
            case 5
                marker_des = integral_invariant_dist(marker_xyz, 20);
            case 6
                marker_des = integral_invariant_dist_mkn(marker_xyz, 60);
            case 8
                NaN_index = isnan(marker_xyz(:, 1));
                marker_xyz(NaN_index, :) = [];
                nsamp1 = size(marker_xyz, 1);
                % outliers on each iteration
                out_vec_1 = zeros(1, nsamp1 - 4); % beginning and ending elements are excluded
                % Frenet Frames
                FrenetVector = Estimate_Frenet(marker_xyz, 20);
                FVector = FrenetVector(3:end - 2, :);
                % compute shape contexts for (transformed) model
                Bsamp = marker_xyz(3:end - 2, :);
                [BH_theta, BH_alpha, mean_dist_1] = sc3d_compute(Bsamp', FVector', mean_dist_global, nbins_theta, nbins_alpha, nbins_r, r_inner, r_outer, out_vec_1);
                marker_des = cat(2, BH_theta, BH_alpha);
            case 9
                NaN_index = isnan(marker_xyz(:, 1));
                marker_xyz(NaN_index, :) = [];
                marker_des = Moment_Invariant(marker_xyz);
            otherwise
                error('IID:unsupportedDescriptorFlag', 'Unsupported descrip_flag: %d', descrip_flag);
        end
        TRAJSAMPLES_DES{1, i} = marker_des;
    end

    samples_r = size(TRAJDB_DES, 2);
    samples_t = size(TRAJSAMPLES_DES, 2);
    dtw_distance = zeros(samples_t, samples_r);
    for i = 1:samples_t
        for j = 1:samples_r
            fprintf ('the %d/%d--%d recognition for %dth descriptor...%2.2f%%\n', i, j, samples_r * samples_t, descrip_flag, (samples_r * (i - 1) + j) * 100 / (samples_r * samples_t));
            %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i, j), ~, ~] = dtw_adj_matching(TRAJSAMPLES_DES{1, i}, TRAJDB_DES{1, j}, 100, descrip_flag);
        end
    end
    [V I] = min(dtw_distance, [], 2); % sum up the recognition accurate ratio
    I'
    for i = 1:16
        for j = 1:16
            confusion_matrix(i, j) = length(find(testGID == i & trainGID(I) == j));
        end
    end
    recog_ratio_interg(experiment_num) = trace(confusion_matrix) / sum(confusion_matrix(:));
    confusion_matrix_interg{1, experiment_num} = confusion_matrix;
    distance_matrix_interg{1, experiment_num} = dtw_distance;
end

%% save TRAJDB original_trajectory;save TRAJSAMPLES noise_trajectory;
% for i = 1:16
%     plot3d(original_trajectory{i});
%     xlabel('X','FontWeight','bold');ylabel('Y','FontWeight','bold');zlabel('Z','FontWeight','bold');
%     saveas(gcf,num2str(i),'png')
% end
% for i = 1:16
%     plot3d(noise_trajectory{i});
%     xlabel('X','FontWeight','bold');ylabel('Y','FontWeight','bold');zlabel('Z','FontWeight','bold');
%     saveas(gcf,strcat(num2str(i),'samples'),'png')
% end

%% plot the dtw illustration
% plot3d(original_trajectory{1});hold on, plot3d(noise_trajectory{1}); hold on;
% for i = 1:size(path,1)
%     plot3([original_trajectory{1}(path(i,1),1) noise_trajectory{1}(path(i,2),1)],...
%          [original_trajectory{1}(path(i,1),2) noise_trajectory{1}(path(i,2),2)],...
%          [original_trajectory{1}(path(i,1),3) noise_trajectory{1}(path(i,2),3)]), hold on;
% end
%% plot distance matrix
m = length(distance_matrix_interg);
n = size(distance_matrix_interg{1, 1}, 1);
confusion_sum = zeros(n, n);
for i = 1:n
    %     name_class{i}=['class_' num2str(i)];
    name_class{i} = num2str(i);
end
for i = 1:m
    if ~isempty(distance_matrix_interg{1, i})
        distance_matrix_interg{1, i} = distance_matrix_interg{1, i} ./ repmat(sum(distance_matrix_interg{1, i}, 2), 1, n);
        distance_matrix_interg{1, i} = distance_matrix_interg{1, i} * 100;
        confusion_sum = confusion_sum + distance_matrix_interg{1, i};
    else
        i = i - 1;
        break;
    end
end
distance_table_interg = confusion_sum / i;
figure(1), draw_cm(distance_table_interg, name_class, n);
% saveas(gcf,strcat('dtw_distance_matching_',...
%     num2str(level)),'fig');
%% for occlusion
saveas(gcf, strcat('dtw_distance_matching_', ...
                   num2str(level), '_occlusion_', num2str(occlu_ratio), '_descrip_', num2str(descrip_flag)), 'fig');
