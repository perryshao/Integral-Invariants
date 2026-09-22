%% plot noise varing with no occlusion using different descriptors
noise =[];ratio =[];
descrip_flag = [3 2 5 1 4 6 7];
descrip_flag = [8];
for i = 1:length(descrip_flag)
    noise{i}(1) = 0;noise{i}(2) = 0.01;noise{i}(3) = 0.02;noise{i}(4) = 0.04;
    noise{i}(5) = 0.08;noise{i}(6) = 0.10;noise{i}(7) = 0.15;noise{i}(8) = 0.20;
    load (['matching_results_000_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(1) = mean(recog_ratio_interg);
    load (['matching_results_001_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(2) = mean(recog_ratio_interg);
    load (['matching_results_002_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(3) = mean(recog_ratio_interg);
    load (['matching_results_004_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(4) = mean(recog_ratio_interg);
    load (['matching_results_008_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(5) = mean(recog_ratio_interg);
    load (['matching_results_010_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(6) = mean(recog_ratio_interg);
    load (['matching_results_015_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(7) = mean(recog_ratio_interg);
    load (['matching_results_020_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(8) = mean(recog_ratio_interg);
end
figure(1),clf,hold on;
%     temp_indx = find(ClusterID == i);
cVec = 'bgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykm';
sVec = 'oxv*sdp';
for j = 1:length(descrip_flag)
    plot(noise{j},ratio{j},[cVec(j) '-' sVec(j)],'LineWidth',2,'MarkerSize',8);grid on;
end
axis([0 0.2 0 1])
legend('AII','DI','DII','FD','MAII','MDII','SSM');
%% plot no noise with occlusion varing using different descriptors
occlusion =[]; ratio =[];
descrip_flag = [3 2 5 1 4 6];
descrip_flag = [8];
for i = 1:length(descrip_flag)
    occlusion{i}(1) = 0.0;occlusion{i}(2) = 0.1;occlusion{i}(3) = 0.2;
    occlusion{i}(4) = 0.3;occlusion{i}(5) = 0.4;
    load (['matching_results_000_occlusion_000_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(1) = mean(recog_ratio_interg);
    load (['matching_results_000_occlusion_010_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(2) = mean(recog_ratio_interg);
    load (['matching_results_000_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(3) = mean(recog_ratio_interg);
    load (['matching_results_000_occlusion_030_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(4) = mean(recog_ratio_interg);
    load (['matching_results_000_occlusion_040_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(5) = mean(recog_ratio_interg);
end
figure(2),clf,hold on;
%     temp_indx = find(ClusterID == i);
cVec = 'bgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykm';
sVec = 'oxv*sd';
for j = 1:length(descrip_flag)
    plot(occlusion{j},ratio{j},[cVec(j) '-' sVec(j)],'LineWidth',2,'MarkerSize',8);grid on;
end
axis([0.0 0.4 0 1])
legend('AII','DI','DII','FD','MAII','MDII');

%% plot noise varing with fixed occlusion using different descriptors
noise =[]; ratio =[];
descrip_flag = 3;
for i = 1:length(descrip_flag)
    noise{i}(1) = 0.01;noise{i}(2) = 0.02;noise{i}(3) = 0.04;
    noise{i}(4) = 0.08;noise{i}(5) = 0.10;noise{i}(6) = 0.15;noise{i}(7) = 0.20;
    load (['matching_results_001_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(1) = mean(recog_ratio_interg);
    load (['matching_results_002_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(2) = mean(recog_ratio_interg);
    load (['matching_results_004_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(3) = mean(recog_ratio_interg);
    load (['matching_results_008_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(4) = mean(recog_ratio_interg);
    load (['matching_results_010_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(5) = mean(recog_ratio_interg);
    load (['matching_results_015_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(6) = mean(recog_ratio_interg);
    load (['matching_results_020_occlusion_020_desp_' num2str(descrip_flag(i)) '.mat'])
    ratio{i}(7) = mean(recog_ratio_interg);
end
figure(3),clf,hold on;
%     temp_indx = find(ClusterID == i);
cVec = 'bgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykmbgrcykm';
sVec = 'oxv*sd';
for j = 1:length(descrip_flag)
    plot(noise{j},ratio{j},[cVec(j) '-' sVec(j)]?,'LineWidth',2,'MarkerSize',8);grid on;
end
axis([0 0.2 0 1])
legend('AII','DI','DII','FD','MAII','MDII');

